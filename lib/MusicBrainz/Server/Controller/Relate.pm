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

sub url : Chained('entity') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $entity = $c->stash->{entity};

    my $form = $self->form;
    $form->init($entity);

    return unless $self->submit_and_validate($c);

    $form->create_relationship;

    $c->response->redirect($c->entity_url($entity, 'relations'));
}

sub cc : Chained('entity') Form('Relate::AddCCLicense')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $entity = $c->stash->{entity};

    my $form = $self->form;
    $form->init($entity);

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

sub cancel : Local
{
    my ($self, $c) = @_;

    $c->session->{current_relationship} = undef;
    $c->response->redirect($c->req->referer);
}

sub create : Chained('entity') PathPart('to') Args(2) Form
{
    my ($self, $c, $dest_type, $dest_id) = @_;

    die "$dest_type is not a valid entity type"
        unless MusicBrainz::Server::LinkEntity->IsValidType($dest_type eq 'release' ? 'album' : $dest_type);

    $c->stash->{source} = $c->stash->{entity};
    $c->stash->{dest  } = $c->model(ucfirst $dest_type)->load($dest_id);

    my $source = $c->stash->{source};
    my $dest   = $c->stash->{dest};

    die "Cannot relate an entity to itself"
	if $source->id eq $dest->id;
}

sub edit_all : Local
{
    my ($self, $c, $type, $id) = @_;

    $c->forward('/user/login');

    my $entity = $c->model($type)->load($id);

    $c->stash->{entity   } = $entity;
    $c->stash->{relations} = $c->model('Relation')->load_relations($entity, to_type => [ 'artist', 'url', 'label', 'album' ]);
}

sub remove : Local Args(3) Form
{
    my ($self, $c, $source_type, $dest_type, $rel_id) = @_;

    $c->forward('/user/login');

    my $relationship = $c->model('Relation')->load($source_type, $dest_type, $rel_id);

    my $source = $c->model($source_type)->load($relationship->{link0});
    my $dest   = $c->model($dest_type)->load($relationship->{link1});

    $c->stash->{relationship} = $relationship;
    $c->stash->{source}       = $source;
    $c->stash->{dest}         = $dest;

    return unless $self->submit_and_validate($c);

    $c->model('Relation')->remove_link($source, $dest, $rel_id, $self->form->value('edit_note'));

    $c->response->redirect($c->entity_url($source, 'show'));
}

1;
