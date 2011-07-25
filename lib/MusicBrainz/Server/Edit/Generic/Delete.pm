package MusicBrainz::Server::Edit::Generic::Delete;
use Moose;
use MooseX::ABC;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Types qw( :edit_status );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
requires '_delete_model';

sub edit_conditions
{
    return {
        $QUALITY_LOW => {
            duration      => 4,
            votes         => 1,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 0,
        },
        $QUALITY_NORMAL => {
            duration      => 14,
            votes         => 3,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 0,
        },
        $QUALITY_HIGH => {
            duration      => 14,
            votes         => 4,
            expire_action => $EXPIRE_REJECT,
            auto_edit     => 0,
        },
    };
}

sub alter_edit_pending
{
    my $self = shift;
    my $model = $self->c->model( $self->_delete_model);
    if ($model->does('MusicBrainz::Server::Data::Role::Editable')) {
        return {
            $self->_delete_model => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub _build_related_entities
{
    my $self = shift;
    my $model = $self->c->model( $self->_delete_model);
    if ($self->status != $STATUS_APPLIED &&
            $model->does('MusicBrainz::Server::Data::Role::LinksToEdit')) {
        return {
            $model->edit_link_table => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub entity_id { shift->data->{entity_id} }

has '+data' => (
    isa => Dict[
        entity_id => Int,
        name      => Str
    ]
);

sub foreign_keys {
    my ($self) = @_;
    return {
        $self->_delete_model => [ $self->data->{entity_id} ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $model = $self->_delete_model;
    return {
        entity => $loaded->{$model}->{$self->data->{entity_id}} ||
            $self->c->model($model)->_entity_class->new(
                name => $self->data->{name}
            )
    };
}

sub initialize
{
    my ($self, %args) = @_;
    my $entity = delete $args{to_delete} or die "Required 'to_delete' object";

    $self->data({
        name      => $entity->name,
        entity_id => $entity->id,
    });
}

override 'accept' => sub
{
    my $self = shift;
    my $model = $self->c->model( $self->_delete_model );

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This entity cannot currently be deleted due to related data.'
    ) unless $model->can_delete( $self->entity_id );

    $model->delete($self->entity_id);
};

__PACKAGE__->meta->make_immutable;

no Moose;
1;
