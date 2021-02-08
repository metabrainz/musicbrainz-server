package MusicBrainz::Server::Controller::Discourse;

use DBDefs;
use Digest::SHA qw( hmac_sha256_hex );
use HTTP::Request::Common qw( GET POST );
use JSON qw( decode_json );
use LWP::UserAgent;
use MIME::Base64 qw( decode_base64 encode_base64 );
use Moose;
use MusicBrainz::Server::Data::Utils qw( non_empty );
use URI;
use URI::Escape qw( uri_escape_utf8 );
use URI::QueryParam;

BEGIN { extends 'MusicBrainz::Server::Controller' }

has lwp => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $lwp = LWP::UserAgent->new;
        $lwp->env_proxy;
        $lwp->timeout(5);
        $lwp->agent(DBDefs->LWP_USER_AGENT);
        $lwp->default_header('Api-Key' => DBDefs->DISCOURSE_API_KEY);
        $lwp->default_header('Api-Username' => DBDefs->DISCOURSE_API_USERNAME);
        $lwp;
    },
);

sub _create_payload {
    my ($nonce, $user) = @_;

    my $uri = URI->new;
    $uri->query_param_append('nonce', $nonce) if $nonce;
    $uri->query_param_append('external_id', $user->id);
    $uri->query_param_append('username', $user->name);
    $uri->query_param_append('email', $user->email);
    $uri->query_param_append('custom.is_auto_editor', $user->is_auto_editor);

    my $sso = encode_base64($uri->query);
    my $sig = hmac_sha256_hex($sso, DBDefs->DISCOURSE_SSO_SECRET);
    return ($sso, $sig);
}

sub _create_uri {
    my ($path) = @_;

    my $uri = URI->new(DBDefs->DISCOURSE_SERVER);
    $uri->path($path);
    $uri;
}

sub sso : Path('/discourse/sso') Args(0) RequireAuth {
    my ($self, $c) = @_;

    unless ($c->user->has_confirmed_email_address) {
        $c->stash(
          current_view => 'Node',
          component_path => 'account/sso/DiscourseUnconfirmedEmailAddress'
        );
        $c->detach;
    }

    my $sso = $c->request->query_params->{sso};
    my $sig = $c->request->query_params->{sig};

    $self->error($c, message => 'empty params')
        unless non_empty($sso) && non_empty($sig);

    my $digest = hmac_sha256_hex($sso, DBDefs->DISCOURSE_SSO_SECRET);

    $self->error($c, message => 'bad sig')
        unless $sig eq $digest;

    my $uri = URI->new;
    $uri->query(decode_base64($sso));
    my $payload = $uri->query_form_hash;
    my $nonce = $payload->{nonce};
    my $return_sso_url = $payload->{return_sso_url};

    $self->error($c, message => 'bad payload')
        unless non_empty($nonce) && non_empty($return_sso_url);

    ($sso, $sig) = _create_payload($nonce, $c->user);
    $uri = URI->new($return_sso_url);
    $uri->query_param_append('sso', $sso);
    $uri->query_param_append('sig', $sig);
    $c->response->redirect($uri);
}

sub sync_sso : Private {
    my ($self, $c, $user) = @_;

    return unless DBDefs->DISCOURSE_SERVER;

    my $uri = _create_uri('/admin/users/sync_sso');
    my ($sso, $sig) = _create_payload(undef, $user);
    $self->lwp->request(POST $uri, [sso => uri_escape_utf8($sso), sig => uri_escape_utf8($sig)]);
}

sub log_out : Private {
    my ($self, $c, $user) = @_;

    return unless DBDefs->DISCOURSE_SERVER;

    my $uri = _create_uri('/users/by-external/' . $user->id . '.json');
    my $response = $self->lwp->request(GET $uri);
    my $user_json = decode_json($response->content);
    my $user_id = $user_json->{user}{id};

    $uri = _create_uri('/admin/users/' . $user_id . '/log_out');
    $self->lwp->request(POST $uri);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
