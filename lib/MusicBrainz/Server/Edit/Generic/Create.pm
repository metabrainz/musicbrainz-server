package MusicBrainz::Server::Edit::Generic::Create;
use Moose;
use MooseX::ABC;

use Clone qw( clone );
use MusicBrainz::Server::Data::Utils qw( model_to_type );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Insert';

requires '_create_model';

sub edit_kind { 'add' }

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

sub _build_related_entities
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

    # Make a copy of the data so we don't accidently modify it
    my $hash   = $self->_insert_hash(clone($self->data));
    my $entity = $self->c->model( $self->_create_model )->insert( $hash );

    $self->entity_id($entity->{id});
    $self->entity_gid($entity->{gid}) if exists $entity->{gid};
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

__PACKAGE__->meta->make_immutable;
no Moose;

1;
