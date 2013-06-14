package MusicBrainz::Server::Authentication::Credential;
use strict;
use warnings;

sub new {
    my ($class, $config, $app, $realm) = @_;
    return $class;
}

sub authenticate {
    my ($self, $c, $realm, $authinfo) = @_;
    if (my $user = $realm->find_user($authinfo, $c)) {
        return $user if $user->match_password($authinfo->{password});
    }

    return;
}

1;
