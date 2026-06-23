package MusicBrainz::Server::Controller::MetaBrainz;

use Digest::SHA qw( hmac_sha256_hex );
use English;
use HTTP::Request::Common qw( POST );
use IO::Uncompress::Gunzip qw( gunzip $GunzipError );
use IO::Compress::Gzip qw( gzip $GzipError );
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
use MusicBrainz::Server::Authentication::Utils qw(
    oauth_expires_in_to_iso8601
    set_remember_login_cookie
);
use MusicBrainz::Server::Data::Utils qw( generate_token non_empty );
use MusicBrainz::Server::Validation qw( is_database_row_id );
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

sub _save_oauth2_redirect_state {
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

    # Only the session which initiated the login should be able to complete
    # the callback, so store the sessionid in state. `$c->session` is called
    # first to create a session if one doesn't already exist.
    #
    # The main reason we don't simply store `oauth2_redirect_state:` in
    # `$c->session` is that we set a custom expiration on the keys, and also
    # use `set_raw` to avoid unnecessary encoding.
    $c->session;
    my $session_id = $c->sessionid;

    my $state_id = generate_token();

    my $state = {
        method => $req_method,
        uri => $saved_uri,
        body_params => $req_body_params,
        origin => $req_origin,
        session_id => $session_id,
    };

    my $encoded_state = $c->json_utf8->encode($state);
    my $compressed_state;
    gzip(\$encoded_state => \$compressed_state)
        or die qq(gzip failed: $GzipError);

    my $store = $c->model('MB')->context->store;
    my $store_key = "oauth2_redirect_state:$state_id";
    $store->set_raw($store_key, $compressed_state, $REDIRECT_STATE_EXPIRES);

    return $state_id;
}

sub _restore_oauth2_redirect_state {
    my ($self, $c, $state_id) = @_;

    my $store = $c->model('MB')->context->store;
    my $store_key = "oauth2_redirect_state:$state_id";
    my $compressed_state = $store->get_delete_raw($store_key);
    my $state;

    if (defined $compressed_state) {
        my $encoded_state;
        gunzip(\$compressed_state => \$encoded_state)
            or die qq(gunzip failed: $GunzipError);
        $state = $c->json_utf8->decode($encoded_state);
    }

    unless (defined $state && ref($state) eq 'HASH') {
        $c->stash->{message} = 'This page has expired.';
        $c->detach('/error_400');
    }

    return $state;
}

sub oauth2_redirect : Private {
    my ($self, $c, $local_path, $login_hint) = @_;

    my $state_id = $self->_save_oauth2_redirect_state($c, $local_path);

    my $uri = URI->new(DBDefs->METABRAINZ_URL . '/oauth2/authorize');
    $uri->query_param_append('response_type', 'code');
    $uri->query_param_append('client_id', DBDefs->METABRAINZ_OAUTH_CLIENT_ID);
    $uri->query_param_append('scope', 'profile');
    $uri->query_param_append('redirect_uri', $c->uri_for('/metabrainz/oauth2/callback'));
    $uri->query_param_append('state', $state_id);
    $uri->query_param_append('login_hint', $login_hint)
        if defined $login_hint;
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

    my $state = $self->_restore_oauth2_redirect_state($c, $state_id);

    my $session_id = $state->{session_id};
    unless (
        non_empty($session_id) &&
        non_empty($c->sessionid) &&
        String::Compare::ConstantTime::equals($session_id, $c->sessionid)
    ) {
        die 'Invalid session_id in OAuth2 redirect state.';
    }

    my $method = $state->{method};
    unless (defined $method && ($method eq 'GET' || $method eq 'POST')) {
        die 'Invalid request method in OAuth2 redirect state.';
    }

    my $uri = URI->new($state->{uri} // '');
    if (
        (
            non_empty($uri->scheme) &&
            $uri->scheme ne $c->req->uri->scheme
        ) ||
        (
            non_empty($uri->authority) &&
            $uri->authority ne $c->req->uri->authority
        )
    ) {
        die 'Invalid URI in OAuth2 redirect state.';
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
            redirect_uri  => $c->uri_for('/metabrainz/oauth2/callback'),
            client_id     => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
            client_secret => DBDefs->METABRAINZ_OAUTH_CLIENT_SECRET,
        ],
    );
    unless ($token_response->is_success) {
        die 'An internal error occurred while fetching the access token.';
    }

    my $token_data = $c->json_utf8->decode($token_response->content);
    my $access_token = $token_data->{access_token};

    my $user = $c->authenticate({
        oauth_access_token => $access_token,
    }, 'website_oauth');

    unless (defined $user) {
        die 'Failed to authenticate the requested user.';
    }

    if ($token_data->{remember_me}) {
        set_remember_login_cookie($c, $user->id, {
            remember_login_token => generate_token(),
            access_token => $access_token,
            access_token_expiration => oauth_expires_in_to_iso8601($token_data->{expires_in}),
            refresh_token => $token_data->{refresh_token},
        });
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

sub _user_created_handler {
    my ($c, $payload) = @_;

    my $user_id = $payload->{user_id};
    die 'Invalid user_id' unless is_database_row_id($user_id);

    $c->model('MB')->with_transaction(sub {
        $c->model('Editor')->insert_from_metabrainz(
            $user_id,
            $payload->{name},
            $payload->{member_since},
        );
    });
    return;
}

sub _user_deleted_handler {
    my ($c, $payload) = @_;

    my $user_id = $payload->{user_id};
    die 'Invalid user_id' unless is_database_row_id($user_id);

    my $editor = $c->model('Editor')->get_by_id($user_id);
    return unless defined $editor && !$editor->deleted;

    $c->model('MB')->with_transaction(sub {
        $c->model('Editor')->delete($user_id);
    });

    $c->forward('/discourse/sync_sso', [$editor]);
    $c->forward('/discourse/log_out', [$editor]);
    return;
}

sub _user_updated_handler {
    my ($c, $payload) = @_;

    # Note that we use all of the `old` values in the payload to match a
    # record in our editor table, not just the user ID. This is so that
    # the handler remains idempotent. Webhooks guarantee "at least once"
    # delivery, so the same event may be delivered twice if, for example,
    # there was a network issue sending our acknowledgment. Verifying the
    # old values thus ensures there hasn't been any unexpected change in
    # state.

    my $user_id = $payload->{user_id};
    die 'Invalid user_id' unless is_database_row_id($user_id);

    my $editor = $c->model('Editor')->get_by_id($user_id);
    die 'Editor does not exist or was deleted'
        unless defined $editor && !$editor->deleted;

    my $old = $payload->{old};
    my $new = $payload->{new};

    my (@conditions, @updates, @params);
    push @params, $user_id;
    push @conditions, 'id = $' . scalar(@params);

    if (exists $old->{email}) {
        push @params, $old->{email};
        # `IS NOT DISTINCT FROM` allows for `NULL = NULL` comparisons.
        push @conditions, 'email IS NOT DISTINCT FROM $' . scalar(@params);

        push @params, $new->{email};
        push @updates, 'email = $' . scalar(@params);

        push @params, $payload->{updated_at};
        push @updates, 'email_confirm_date = $' . scalar(@params);
    }

    if (exists $old->{name}) {
        push @params, $old->{name};
        push @conditions, 'name = $' . scalar(@params);

        push @params, $new->{name};
        push @updates, 'name = $' . scalar(@params);
    }

    die 'Malformed user.updated payload (no updates?)'
        unless @updates;

    my $query = 'UPDATE editor SET ' .
        (join q(, ), @updates) .
        ' WHERE ' .
        (join q( AND ), @conditions);

    my $model = $c->model('MB');
    my $sql = $model->context->sql;
    my $is_new_data_applied = 0;

    $model->with_transaction(sub {
        my $row_count = $sql->do($query, @params);

        if ($row_count == 0) {
            # There were no rows matching this user ID + `old` data. Check
            # if the user ID + `new` data matches an existing row before
            # returning an error response.
            @params = ();
            @conditions = ();
            push @params, $user_id;
            push @conditions, 'id = $1';

            if (exists $new->{email}) {
                push @params, $new->{email};
                push @conditions, 'email IS NOT DISTINCT FROM $' . scalar(@params);

                push @params, $payload->{updated_at};
                push @conditions, 'email_confirm_date = $' . scalar(@params);
            }

            if (exists $new->{name}) {
                push @params, $new->{name};
                push @conditions, 'name = $' . scalar(@params);
            }

            $query = 'SELECT 1 FROM editor WHERE ' .
                (join q( AND ), @conditions);
            $is_new_data_applied =
                $sql->select_single_value($query, @params) // 0;
        } else {
            $is_new_data_applied = 1;
        }
    });

    die 'Neither the old nor new values in the payload match the current ' .
        'editor row data.'
        unless $is_new_data_applied;

    $editor = $c->model('Editor')->get_by_id($user_id);
    $c->forward('/discourse/sync_sso', [$editor]);

    return;
}

Readonly our %webhook_handlers => (
    'user.created' => \&_user_created_handler,
    'user.deleted' => \&_user_deleted_handler,
    'user.updated' => \&_user_updated_handler,
);

sub _verify_webhook_signature {
    my ($self, $c, $payload_bytes, $signature_header) = @_;

    return 0 unless $signature_header && $signature_header =~ /^sha256=/;

    my $provided_signature = substr($signature_header, 7);
    my $expected_signature = hmac_sha256_hex($payload_bytes, DBDefs->METABRAINZ_WEBHOOK_SECRET);
    return String::Compare::ConstantTime::equals($expected_signature, $provided_signature);
}

sub _webhook_error_response {
    my ($self, $c, $status, $message) = @_;

    my $res = $c->response;
    $res->status($status);
    $res->content_type('application/json');
    $res->body($c->json_utf8->encode({
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
    my $signature = $req->header('X-MetaBrainz-Signature-256');

    unless (
        non_empty($event_type) &&
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
        sub {
            $payload = $c->json_utf8->decode($payload_bytes);
        },
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
            $res->body($c->json_utf8->encode({ status => 'success' }));
        },
        sub {
            my $error = shift;
            $c->log->error($error);
            $self->_webhook_error_response(
                $c,
                500,
                'Internal error processing webhook (check Sentry)',
            );
        },
    );

    return;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
