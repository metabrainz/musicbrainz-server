package MusicBrainz::Server::Edit::Generic::Edit;
use Moose;
use MooseX::ABC;

use Clone qw( clone );
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit::WithDifferences';
requires 'change_fields', '_edit_model';

sub entity_id { shift->data->{entity}{id} }

sub alter_edit_pending
{
    my $self = shift;
    my $model = $self->c->model( $self->_edit_model);
    if ($model->does('MusicBrainz::Server::Data::Role::Editable')) {
        return {
            $self->_edit_model => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub related_entities
{
    my $self = shift;
    my $model = $self->c->model( $self->_edit_model);
    if ($model->does('MusicBrainz::Server::Data::Role::LinksToEdit')) {
        return {
            $model->edit_link_table => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub initialize
{
    my ($self, %opts) = @_;
    my $entity = delete $opts{to_edit};
    die "You must specify the object to edit" unless defined $entity;

    $self->data({
        entity => {
            id => $entity->id,
            name => $entity->name
        },
        $self->_change_data($entity, %opts)
    });
};

override 'accept' => sub
{
    my $self = shift;
    my $data = $self->_edit_hash(clone($self->data->{new}));
    $self->c->model( $self->_edit_model )->update($self->entity_id, $data);
};

sub _edit_hash
{
    my ($self, $data) = @_;
    return $data;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
