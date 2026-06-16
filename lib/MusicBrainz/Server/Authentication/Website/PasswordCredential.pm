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

    unless (defined $user) {
        $c->stash( bad_login => 1 );
        return;
    }

    unless (can_user_login($user)) {
        if ($user->is_spammer) {
            $c->stash( spammy_login => 1 );
        } else {
            $c->stash( bad_login => 1 );
        }
        return;
    }

    unless (
        non_empty($user->password) &&
        $user->match_password($auth_info->{password})
    ) {
        $c->stash( bad_login => 1 );
        return;
    }

    return $user;
}

1;
