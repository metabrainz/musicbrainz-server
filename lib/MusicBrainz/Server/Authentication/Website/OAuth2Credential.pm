package MusicBrainz::Server::Authentication::Website::OAuth2Credential;

use strict;
use warnings;

use DBDefs;
use MusicBrainz::Server::Authentication::Utils qw(
    can_user_login
    find_active_metabrainz_oauth_access_token
);

sub new {
    my ($class, $config, $app, $realm) = @_;

    return bless {}, $class;
}

sub authenticate {
    my ($self, $c, $realm, $auth_info) = @_;

    my $access_token = $auth_info->{oauth_access_token};

    return if (
        !defined $access_token ||
        (DBDefs->OAUTH2_ENFORCE_TLS && !$c->req->secure)
    );

    my $token_instance = find_active_metabrainz_oauth_access_token($c, $access_token);
    if (defined $token_instance) {
        my $user = $realm->find_user({
            editor_id => $token_instance->editor_id,
            editor_oauth_token => $token_instance,
        }, $c);
        return unless can_user_login($user);
        return $user;
    }

    return;
}

1;

=head1 DESCRIPTION

A credential verifier for `Catalyst::Plugin::Authentication` that accepts
a MetaBrainz OAuth2 access token for website logins.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
