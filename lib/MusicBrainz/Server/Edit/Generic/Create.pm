package MusicBrainz::Server::Edit::Generic::Create;
use Moose;
use MooseX::ABC;

use MusicBrainz::Server::Data::Utils qw( model_to_type );

extends 'MusicBrainz::Server::Edit';
requires '_create_model';

has 'entity' => (
    isa => 'Entity',
    is  => 'rw'
);

has 'entity_id' => (
    isa => 'Int',
    is  => 'rw'
);

sub alter_edit_pending
{
    my $self = shift;
    my $model = $self->c->model( $self->_create_model);
    if ($model->does('MusicBrainz::Server::Data::Role::Editable')) {
        return {
            $self->_create_model => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub related_entities
{
    my $self = shift;
    my $model = $self->c->model( $self->_create_model);
    if ($model->does('MusicBrainz::Server::Data::Role::LinksToEdit')) {
        return {
            $model->edit_link_table => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub insert
{
    my $self = shift;

    my $data = $self->_insert_hash($self->data);
    my $entity = $self->c->model( $self->_create_model )->insert( $data );

    $self->entity($entity);
    $self->entity_id($entity->id);
}

sub reject
{
    my $self = shift;
    $self->c->model($self->_create_model)->delete($self->entity_id);
}

sub _insert_hash
{
    my ($self, $data) = @_;
    return $data;
}

override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{entity_id} = $self->entity_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->entity_id(delete $hash->{entity_id});
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
