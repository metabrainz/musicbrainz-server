package MusicBrainz::Server::Authentication::Store;

use strict;
use warnings;

sub new
{
    my ($class, $config, $app, $realm) = @_;
    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;
    return $c->model('User')->load({ username => $authinfo->{username} });
}

sub for_session
{
    my ($self, $c, $user) = @_;
    return $user->id;
}

sub from_session
{
    my ($self, $c, $frozen_user) = @_;
    return $c->model('User')->load({ id => $frozen_user });
}

1;
