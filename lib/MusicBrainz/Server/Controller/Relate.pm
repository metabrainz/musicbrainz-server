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

sub create : Chained('entity') PathPart('to') Args(2)
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

    my $form = MusicBrainz::Server::Form->new(
	profile => {
	    required => {
		begin => '+MusicBrainz::Server::Form::Field::Date',
		end   => '+MusicBrainz::Server::Form::Field::Date',
		type  => 'Select',
	    },
	    optional => {
		edit_note  => 'TextArea',
		additional => 'Checkbox',
		co         => 'Checkbox',
		executive  => 'Checkbox',
		guest      => 'Checkbox',
		orchestra  => 'Select',
		instrument => 'Select',
		vocals     => 'Select',
	    },
	},
    );

    $c->stash->{form} = $form;
}

1;
