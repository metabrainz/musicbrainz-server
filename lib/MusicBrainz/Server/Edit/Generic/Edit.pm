package MusicBrainz::Server::Edit::Generic::Edit;
use Moose;
use MooseX::ABC;

use Clone qw( clone );
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

use MusicBrainz::Server::Edit::Exceptions;
use Try::Tiny;

extends 'MusicBrainz::Server::Edit::WithDifferences';
requires 'change_fields', '_edit_model', '_conflicting_entity_path';

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

sub _build_related_entities
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

    if (!$self->c->model($self->_edit_model)->get_by_id($self->entity_id)) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This entity no longer exists'
        )
    }

    my $data = $self->_edit_hash(clone($self->data->{new}));
    try {
        $self->c->model( $self->_edit_model )->update($self->entity_id, $data);
    }
    catch {
        if (blessed($_) && $_->isa('MusicBrainz::Server::Exceptions::DuplicateViolation')) {
            my $conflict = $_->conflict;
            MusicBrainz::Server::Edit::Exceptions::GeneralError->throw(
                sprintf(
                    'The changes in this edit cause it to conflict with another entity. ' .
                    'You may need to merge this entity with "%s" ' .
                    '(//%s%s)',
                    $conflict->name,
                    DBDefs->WEB_SERVER,
                    $self->_conflicting_entity_path($conflict->gid)
                )
            );
        }
    };
};

sub _conflicting_entity_path { die 'Undefined' };

sub _edit_hash
{
    my ($self, $data) = @_;
    return $data;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
