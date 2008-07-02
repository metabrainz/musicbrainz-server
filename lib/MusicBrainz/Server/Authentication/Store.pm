package MusicBrainz::Server::Authentication::Store;

use strict;
use warnings;

use MusicBrainz::Server::Authentication::User;
use MusicBrainz;
use UserStuff;

sub can { 1; }

sub new
{
    my ($class, $config, $app, $realm) = @_;

    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;

    my $mb = $c->mb;

    my $us = UserStuff->new($mb->{DBH});
    my $user = $us->newFromName($authinfo->{username});

    $user ? new MusicBrainz::Server::Authentication::User($user) : undef;
}

sub for_session
{
    my ($self, $c, $user) = @_;

    my $uo = $user->get_object;
    return $uo->GetName;
}

sub from_session
{
    my ($self, $c, $frozenUser) = @_;

    return $self->find_user({ username => $frozenUser }, $c);
}

sub user_support
{
    my $self = shift;
}

1;
