package MusicBrainz::Server::Controller::MetaBrainz;

use Digest::SHA qw( hmac_sha256_hex );
use English;
use HTTP::Request::Common qw( GET POST );
use IO::Uncompress::Gunzip qw( gunzip $GunzipError );
use IO::Compress::Gzip qw( gzip $GzipError );
use JSON::XS qw( encode_json decode_json );
use LWP::UserAgent;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;
use Readonly;
use Scalar::Util qw( looks_like_number );
use String::Compare::ConstantTime;
use URI;
use URI::QueryParam;

use DBDefs;
use MusicBrainz::Errors qw( capture_exceptions );
use MusicBrainz::Server::Constants qw( $BEGINNER_FLAG );
use MusicBrainz::Server::Data::Utils qw( non_empty );
use Readonly;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory';

extends 'MusicBrainz::Server::Controller';

# POST parameters are saved in Valkey so as not to interrupt edit page
# seeding during an OAuth2 redirect. `$MAX_CONTENT_LENGTH` sets an upper
# bound on the incoming request's Content-Length. If exceeded, we don't
# store `$req->body_params` at all in Valkey. 64KB should be plenty for
# a very large release seed.
Readonly our $MAX_CONTENT_LENGTH => 65536; # 64KB

# How long (in seconds) to store `oauth2_redirect_state` keys in Valkey.
Readonly our $REDIRECT_STATE_EXPIRES => 120; # 2 minutes

sub base : Chained('/') PathPart('metabrainz') CaptureArgs(0) { }

sub get_session_id : Private {
    my ($self, $c) = @_;

    # Ensures a session exists before accessing `sessionid`.
    $c->session;
    my $session_id = $c->sessionid;
    # This shouldn't happen, but we want to be sure a session exists before
    # proceeding.
    die 'No sessionid' unless non_empty($session_id);
    return $session_id;
}

sub save_oauth2_redirect_state : Private {
    my ($self, $c, $local_path) = @_;

    my $req = $c->req;
    my $req_method = $req->method;
    my $saved_uri = $req->uri->path eq $local_path
        ? $c->get_returnto_param
        : $req->uri->as_string;
    my $req_body_params = (
        (
            $req_method eq 'POST' &&
            looks_like_number($req->content_length) &&
            $req->content_length <= $MAX_CONTENT_LENGTH
        )
            ? $req->body_params
            : {}
    );
    my $req_origin = $req->header('Origin');
    my $session_id = $self->get_session_id($c);
    my $state_id = $c->generate_nonce;

    my $state = {
        id => $state_id,
        method => $req_method,
        uri => $saved_uri,
        body_params => $req_body_params,
        origin => $req_origin,
    };

    my $encoded_state = $c->json_utf8->encode($state);
    my $compressed_state;
    gzip(\$encoded_state => \$compressed_state)
        or die qq(gzip failed: $GzipError);

    my $store = $c->model('MB')->context->store;
    my $store_key = "oauth2_redirect_state:$session_id";
    $store->set_raw($store_key, $compressed_state, $REDIRECT_STATE_EXPIRES);

    return $state_id;
}

sub restore_oauth2_redirect_state : Private {
    my ($self, $c, $state_id) = @_;

    my $session_id = $self->get_session_id($c);
    my $store = $c->model('MB')->context->store;
    my $store_key = "oauth2_redirect_state:$session_id";
    my $compressed_state = $store->get_raw($store_key);
    $store->delete($store_key);
    my $state;

    if (defined $compressed_state) {
        my $encoded_state;
        gunzip(\$compressed_state => \$encoded_state)
            or die qq(gunzip failed: $GunzipError);
        $state = $c->json_utf8->decode($encoded_state);
    }

    unless (
        defined $state &&
        ref($state) eq 'HASH' &&
        ($state->{id} // '') eq $state_id
    ) {
        $c->stash->{message} = 'This page has expired.';
        $c->detach('/error_400');
    }

    return $state;
}

sub oauth2_redirect : Private {
    my ($self, $c, $local_path, $login_hint) = @_;

    my $state_id = $self->save_oauth2_redirect_state($c, $local_path);

    my $uri = URI->new(DBDefs->METABRAINZ_URL . '/oauth2/authorize');
    $uri->query_param_append('response_type', 'code');
    $uri->query_param_append('client_id', DBDefs->METABRAINZ_OAUTH_CLIENT_ID);
    $uri->query_param_append('scope', 'profile');
    $uri->query_param_append('redirect_uri', $c->uri_for('/metabrainz/oauth2/callback'));
    $uri->query_param_append('state', $state_id);
    $uri->query_param_append('login_hint', $login_hint);
    $c->res->redirect($uri);
}

sub oauth2_callback : Chained('base') PathPart('oauth2/callback') Args(0) {
    my ($self, $c) = @_;

    $c->res->headers->header(
        'Cache-Control' => 'no-store',
        'Pragma' => 'no-cache',
        'Referrer-Policy' => 'strict-origin-when-cross-origin',
    );

    my $query_params = $c->req->query_params;

    my $code = $query_params->{code};
    unless (non_empty($code)) {
        $c->stash->{message} = 'A required parameter ("code") is missing.';
        $c->detach('/error_400');
    }

    my $state_id = $query_params->{state};
    unless (non_empty($state_id)) {
        $c->stash->{message} = 'A required parameter ("state") is missing.';
        $c->detach('/error_400');
    }

    my $lwp = LWP::UserAgent->new;
    $lwp->env_proxy;
    $lwp->timeout(5);
    $lwp->agent(DBDefs->LWP_USER_AGENT);

    my $token_uri = DBDefs->METABRAINZ_INTERNAL_URL . '/oauth2/token';
    my $token_response = $lwp->request(POST $token_uri,
        [
            grant_type    => 'authorization_code',
            code          => $code,
            redirect_uri  => $c->uri_for_action($c->action),
            client_id     => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
            client_secret => DBDefs->METABRAINZ_OAUTH_CLIENT_SECRET,
        ],
    );
    unless ($token_response->is_success) {
        die 'An internal error occurred while fetching the access token.';
    }

    my $token_data = decode_json($token_response->decoded_content);
    my $access_token = $token_data->{access_token};

    my $user = $c->authenticate({
        oauth_access_token => $access_token,
    }, 'website_oauth');

    unless (defined $user) {
        die 'Failed to authenticate the requested user.';
    }

    my $state = $self->restore_oauth2_redirect_state($c, $state_id);
    my $method = $state->{method};

    unless (defined $method && ($method eq 'GET' || $method eq 'POST')) {
        die 'Invalid request method in pre-login state.';
    }

    my $uri = URI->new($state->{uri} // '');
    unless (
        !non_empty($uri->authority) ||
        $uri->authority eq $c->req->uri->authority
    ) {
        die 'Invalid URI in pre-login state.';
    }

    if ($method eq 'GET') {
        $c->res->redirect($uri);
    } elsif ($method eq 'POST') {
        $c->set_csp_headers;
        $c->stash(
            current_view => 'Node',
            component_path => 'main/ConfirmSeed',
            component_props => {
                origin => $state->{origin} // 'unknown',
                postParameters => $state->{body_params} // {},
                requestUri => $uri->as_string,
            },
        );
    }
}

sub _user_created_handler : Private {
    my ($c, $payload) = @_;

    my $sql = $c->model('MB')->context->sql;
    $sql->begin;
    $c->model('Editor')->insert_from_metabrainz(
        $payload->{user_id},
        $payload->{name},
        $payload->{member_since},
    );
    $sql->commit;
}

sub _user_deleted_handler : Private {
    my ($c, $payload) = @_;

    $c->model('MB')->with_transaction(sub {
        $c->model('Editor')->delete($payload->{user_id});
    });
}

sub _user_updated_handler : Private {
    my ($c, $payload) = @_;

    my $id = $payload->{user_id};
    my $old = $payload->{old};
    my $new = $payload->{new};

    my (@conditions, @updates, @params);
    push @conditions, 'id = $1';
    push @params, $id;

    if (exists $old->{email}) {
        push @conditions, 'email IS NOT DISTINCT FROM $2';
        push @params, $old->{email};

        push @updates, 'email = $3';
        push @params, $new->{email};

        push @updates, 'email_confirm_date = $4';
        push @params, $payload->{updated_at};
    }

    if (exists $old->{name}) {
        push @conditions, 'name = $5';
        push @params, $old->{name};

        push @updates, 'name = $6';
        push @params, $new->{name};
    }

    my $query = 'UPDATE editor SET ' .
        (join q(, ), @updates) .
        ' WHERE ' .
        (join q( AND ), @conditions);

    my $sql = $c->model('MB')->context->sql;
    $sql->begin;
    my $rows = $sql->do($query, @params);
    if ($rows > 0) {
        $sql->commit;
    } else {
        $sql->rollback;
        die 'No editor row was found matching the given user_id ' .
            'and old data columns.';
    }
}

Readonly our %webhook_handlers => (
    'user.created' => \&_user_created_handler,
    'user.deleted' => \&_user_deleted_handler,
    'user.updated' => \&_user_updated_handler,
);

sub _verify_webhook_signature : Private {
    my ($self, $c, $payload_bytes, $signature_header) = @_;

    return 0 unless $signature_header && $signature_header =~ /^sha256=/;

    my $provided_signature = substr($signature_header, 7);
    my $expected_signature = hmac_sha256_hex($payload_bytes, DBDefs->METABRAINZ_WEBHOOK_SECRET);
    return String::Compare::ConstantTime::equals($expected_signature, $provided_signature);
}

sub _webhook_error_response : Private {
    my ($self, $c, $status, $message) = @_;

    my $res = $c->response;
    $res->status($status);
    $res->content_type('application/json');
    $res->body(encode_json({
        status => 'error',
        message => $message,
    }));
}

sub webhook_callback : Chained('base') : PathPart('webhook/callback') : Args(0) {
    my ($self, $c) = @_;

    my $req = $c->request;
    my $res = $c->response;

    my $webhook_secret = DBDefs->METABRAINZ_WEBHOOK_SECRET;
    unless (non_empty($webhook_secret)) {
        $self->_webhook_error_response($c, 503, 'Webhook receiver not properly configured');
        return;
    }

    my $event_type = $req->header('X-MetaBrainz-Event');
    my $delivery_id = $req->header('X-MetaBrainz-Delivery');
    my $signature = $req->header('X-MetaBrainz-Signature-256');

    unless (
        non_empty($event_type) &&
        non_empty($delivery_id) &&
        non_empty($signature)
    ) {
        $self->_webhook_error_response($c, 400, 'Missing required headers');
        return;
    }

    my $payload_bytes;
    {
        my $body = $req->body;
        local $INPUT_RECORD_SEPARATOR;
        $payload_bytes = <$body>;
        $payload_bytes //= '';
    }

    unless ($self->_verify_webhook_signature($c, $payload_bytes, $signature)) {
        $self->_webhook_error_response($c, 401, 'Invalid signature');
        return;
    }

    my ($payload, $failure);
    capture_exceptions(
        sub { $payload = decode_json($payload_bytes) },
        sub {
            $failure = 1;
            $self->_webhook_error_response($c, 400, 'Invalid JSON payload');
        },
    );
    return if $failure;

    my $handler = $webhook_handlers{$event_type};
    unless (defined $handler) {
        $self->_webhook_error_response($c, 400, "Unknown event type: $event_type");
        return;
    }

    capture_exceptions(
        sub {
            $handler->($c, $payload);
            $res->status(200);
            $res->content_type('application/json');
            $res->body(encode_json({ status => 'success' }));
        },
        sub {
            my $error = shift;
            $c->log->error($error);
            $self->_webhook_error_response($c, 500, $error);
        },
    );

    return;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
