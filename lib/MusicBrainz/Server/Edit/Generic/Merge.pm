package MusicBrainz::Server::Edit::Generic::Merge;
use Moose;
use MooseX::ABC;

use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Edit::Exceptions;
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
requires '_merge_model';
with 'MusicBrainz::Server::Edit::Role::NeverAutoEdit';

sub edit_kind { 'merge' }

sub alter_edit_pending
{
    my $self = shift;
    return {
        $self->_merge_model => $self->_entity_ids
    }
}

sub _build_related_entities
{
    my $self = shift;
    return {
        model_to_type($self->_merge_model) => $self->_entity_ids
    }
}

has '+data' => (
    isa => Dict[
        new_entity => Dict[
            id   => Int,
            name => Str
        ],
        old_entities => ArrayRef[ Dict[
            name => Str,
            id   => Int
        ] ]
    ]
);

sub new_entity { shift->data->{new_entity} }

sub foreign_keys
{
    my $self = shift;
    return {
        $self->_merge_model => $self->_entity_ids
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $model = $self->_merge_model;

    my $data = {
        new => $loaded->{ $model }->{ $self->new_entity->{id} } ||
            $self->c->model($model)->_entity_class->new($self->new_entity),
        old => []
    };

    for my $old (@{ $self->data->{old_entities} }) {
        my $ent = $loaded->{ $model }->{ $old->{id} } ||
            $self->c->model($model)->_entity_class->new($old);

        push @{ $data->{old} }, $ent;
    }

    return $data;
}

sub accept
{
    my $self = shift;
    my $model = $self->c->model( $self->_merge_model );
    if (!$model->get_by_id($self->new_entity->{id})) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'The target has been removed since this edit was created'
        );
    }
    if (!values %{ $model->get_by_ids($self->_old_ids) }) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'There are no longer any entities to merge'
        );
    }
    else {
        $self->do_merge;
    }
}

sub do_merge
{
    my $self = shift;
    $self->c->model( $self->_merge_model )->merge($self->new_entity->{id}, $self->_old_ids);
}

sub _entity_ids
{
    my $self = shift;
    return [
        $self->new_entity->{id},
        $self->_old_ids
    ];
}

sub _old_ids
{
    my $self = shift;
    return map { $_->{id} } @{ $self->data->{old_entities} }
}

sub _xml_arguments { ForceArray => ['old_entities'] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

