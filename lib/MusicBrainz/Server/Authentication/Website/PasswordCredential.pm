package MusicBrainz::Server::Authentication::Website::PasswordCredential;

use strict;
use warnings;

use DBDefs;
use MusicBrainz::Server::Authentication::Utils qw( can_user_login );
use MusicBrainz::Server::Data::Utils qw( non_empty );

sub new {
    my ($class, $config, $app, $realm) = @_;

    return bless {}, $class;
}

sub authenticate {
    my ($self, $c, $realm, $auth_info) = @_;

    return unless DBDefs->LOCAL_ACCOUNTS_ENABLED;

    my $user = $realm->find_user($auth_info, $c);

    return unless (
        can_user_login($user) &&
        non_empty($user->password) &&
        $user->match_password($auth_info->{password})
    );

    return $user;
}

1;
