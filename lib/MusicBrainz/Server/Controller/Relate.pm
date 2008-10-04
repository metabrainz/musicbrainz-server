package MusicBrainz::Server::Controller::Relate;

use strict;
use warnings;

use base 'Catalyst::Controller';

sub entity : Chained('/') PathPart('relate') CaptureArgs(2)
{
    my ($self, $c, $type, $id) = @_;

    $c->stash->{entity} = $c->model(ucfirst $type)->load($id);
}

sub url : Chained('entity')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $entity = $c->stash->{entity};

    my $form = $c->form($entity, 'Relate::Url');
}

1;
