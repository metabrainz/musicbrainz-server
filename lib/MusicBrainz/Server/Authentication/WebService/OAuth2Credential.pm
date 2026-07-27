package MusicBrainz::Server::Authentication::WebService::OAuth2Credential;

use strict;
use warnings;

use aliased 'MusicBrainz::Server::Authentication::WebService::OAuth2User' => 'OAuth2User';
use DBDefs;
use MusicBrainz::Server::Authentication::Utils qw( find_active_oauth_access_token );
use MusicBrainz::Server::Data::Utils qw( non_empty );

sub new {
    my ($class, $config, $app, $realm) = @_;

    return bless {}, $class;
}

sub authenticate {
    my ($self, $c, $realm, $auth_info) = @_;

    return if DBDefs->OAUTH2_ENFORCE_TLS && !$c->req->secure;

    my $access_token;
    my @authorization = $c->req->headers->header('Authorization');
    for my $authorization (@authorization) {
        if ($authorization =~ /^\s*Bearer\s+(\S+)\s*$/) {
            $access_token = $1;
            last;
        }
    }
    $access_token //= $c->req->params->{access_token};

    if (non_empty($access_token)) {
        my $token_instance = find_active_oauth_access_token($c, $access_token);
        if (defined $token_instance) {
            my $user = $realm->find_user({ editor_id => $token_instance->editor_id }, $c);
            return unless defined $user;

            OAuth2User->meta->rebless_instance($user);
            $user->oauth_token($token_instance);
            return $user;
        }
    }
    return;
}

1;

=head1 DESCRIPTION

A credential verifier for `Catalyst::Plugin::Authentication` that accepts
an OAuth2 access token, either for MusicBrainz or MetaBrainz.

The token is read from the C<Authorization> header, or the C<access_token>
query parameter as a fallback.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
