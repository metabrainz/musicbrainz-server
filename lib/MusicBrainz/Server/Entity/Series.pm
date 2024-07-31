package MusicBrainz::Server::Entity::Series;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Annotation',
     'MusicBrainz::Server::Entity::Role::Comment',
     'MusicBrainz::Server::Entity::Role::Relatable',
     'MusicBrainz::Server::Entity::Role::Taggable',
     'MusicBrainz::Server::Entity::Role::Type' => { model => 'SeriesType' };

sub entity_type { 'series' }

has ordering_type_id => (
    is => 'rw',
    isa => 'Int',
);

has ordering_type => (
    is => 'rw',
    isa => 'SeriesOrderingType',
);

has entity_count => (
    is => 'rw',
    isa => 'Int',
    predicate => 'loaded_entity_count',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    if (my $ordering_type = $self->ordering_type) {
        $self->link_entity(
            'series_ordering_type',
            $ordering_type->id,
            $ordering_type,
        );
    }

    my $json = $self->$orig;
    $json->{orderingTypeID} = $self->ordering_type_id;

    if ($self->type) {
        $json->{type} = $self->type->TO_JSON;
    }

    if ($self->loaded_entity_count) {
        $json->{entity_count} = $self->entity_count;
    }

    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
