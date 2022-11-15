package MusicBrainz::Server::Edit::Generic::Merge;
use Moose;

use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Role::NeverAutoEdit';

# Sub-classes are required to implement `_merge_model`.
#
# N.B. This is not checked at compile-time.

sub _merge_model { die 'Unimplemented' }

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

sub _build_missing_entity {
    my ($self, $loaded, $data) = @_;

    my $model = $self->_merge_model;
    return $self->c->model($model)->_entity_class->new($data);
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $model = $self->_merge_model;
    my @releases = values %{ $loaded->{Release} };

    # For release merges, we need to load additional data
    # before turning the releases to JSON
    if ($model eq 'Release') {
        $self->c->model('Label')->load(
            grep { $_->label_id && !defined($_->label) }
            map { $_->all_labels }
            @releases
        );

        $self->c->model('Medium')->load_for_releases(
            grep { $_->medium_count < 1 }
            @releases
        );

        $self->c->model('MediumFormat')->load(
            grep { $_->format_id && !defined($_->format) }
            map { $_->all_mediums }
            @releases
        );

        $self->c->model('Release')->load_release_events(
            @releases
        );
    }

    my $new_entity = to_json_object(
        $loaded->{$model}{ $self->new_entity->{id} } ||
        $self->_build_missing_entity($loaded, $self->new_entity)
    );

    my $data = {
        new => $new_entity,
        old => []
    };

    for my $old (@{ $self->data->{old_entities} }) {
        my $ent = $loaded->{$model}{ $old->{id} } ||
            $self->_build_missing_entity($loaded, $old);

        push @{ $data->{old} }, to_json_object($ent);
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
