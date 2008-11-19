package MusicBrainz::Server::Controller::Relate;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

sub entity : Chained('/') PathPart('relate') CaptureArgs(2)
{
    my ($self, $c, $type, $id) = @_;

    die "$type is not a valid entity type"
        unless MusicBrainz::Server::LinkEntity->IsValidType($type eq 'release' ? 'album' : $type);

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

    $form->insert;

    $c->response->redirect($c->entity_url($entity, 'relations'));
}

sub cc : Chained('entity')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $entity = $c->stash->{entity};

    my $form = $c->form($entity, 'Relate::AddCCLicense');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->insert;

    $c->response->redirect($c->entity_url($entity, 'relations'));
}

sub store : Chained('entity')
{
    my ($self, $c) = @_;
    $c->session->{current_relationship} = {
	id   => $c->stash->{entity}->id,
	type => $c->stash->{entity}->entity_type,
    };

    $c->response->redirect($c->req->referer);
}

sub create : Chained('entity') PathPart('to') Args(2)
{
    my ($self, $c, $dest_type, $dest_id) = @_;

    die "$dest_type is not a valid entity type"
        unless MusicBrainz::Server::LinkEntity->IsValidType($dest_type eq 'release' ? 'album' : $dest_type);
}

1;
