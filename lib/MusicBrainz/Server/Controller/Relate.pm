package MusicBrainz::Server::Controller::Relate;

use strict;
use warnings;

use base 'Catalyst::Controller';

sub entity : Chained('/') PathPart('relate') CaptureArgs(2)
{
    my ($self, $c, $type, $id) = @_;

    die "$type is not a valid entity type"
        unless MusicBrainz::Server::LinkEntity->IsValidType($type);

    $c->stash->{entity} = $c->model(ucfirst $type)->load($id);
}

sub url : Chained('entity')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $entity = $c->stash->{entity};

    my $form = $c->form($entity, 'Relate::Url');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->form_relationship;

    $c->response->redirect($c->entity_url($entity, 'relations'));
}

1;
