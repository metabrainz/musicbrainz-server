package MusicBrainz::Server::Authentication::Credential;
use strict;
use warnings;

use DBDefs;

sub new {
    my ($class, $config, $app, $realm) = @_;
    return $class;
}

sub authenticate {
    my ($self, $c, $realm, $authinfo) = @_;

    return unless DBDefs->LOCAL_ACCOUNTS_ENABLED;

    if (my $user = $realm->find_user($authinfo, $c)) {
        return $user if $user->match_password($authinfo->{password}) && !$user->deleted;
    }

    return;
}

1;
