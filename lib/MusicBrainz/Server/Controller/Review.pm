package MusicBrainz::Server::Controller::Review;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

sub user : Chained('/') PathPart('review') CaptureArgs(1)
{
    my ($self, $c, $user_name) = @_;

    $c->stash->{user} = $c->model('User')->load({ username => $user_name });
}

sub votes : Chained('user')
{
    my ($self, $c) = @_;

    $c->stash->{edits} = $c->model('Moderation')->voted_on($c->stash->{user});
    $c->stash->{template} = 'moderation/open.tt';
}

sub edits : Chained('user')
{
    my ($self, $c) = @_;

    $c->stash->{edits} = $c->model('Moderation')->users_edits($c->stash->{user});
    $c->stash->{template} = 'moderation/open.tt';
}

1;
