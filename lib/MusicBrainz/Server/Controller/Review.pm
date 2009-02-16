package MusicBrainz::Server::Controller::Review;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

sub user : Chained('/') PathPart('review') CaptureArgs(1)
{
    my ($self, $c, $user_name) = @_;
    
    $c->forward('/user/login');

    $c->stash->{user} = $c->model('User')->load({ username => $user_name });
}

sub votes : Chained('user')
{
    my ($self, $c) = @_;
    
    my $page = $c->req->query_params->{page} || 1;

    my ($edits, $pager) = $c->model('Moderation')->voted_on($c->stash->{user}, $page);

    $c->stash->{edits} = $edits;
    $c->stash->{pager} = $pager;
    $c->stash->{template} = 'moderation/open.tt';
}

sub edits : Chained('user')
{
    my ($self, $c, $type) = @_;

    $type ||= 'all';

    my $page = $c->req->query_params->{page} || 1;

    my ($edits, $pager) = $c->model('Moderation')->users_edits($c->stash->{user}, $type);

    $c->stash->{edits} = $edits;
    $c->stash->{pager} = $pager;
    $c->stash->{template} = 'moderation/open.tt';
}



1;
