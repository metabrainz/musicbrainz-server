package MusicBrainz::Server::Entity::Series;

use Moose;
use MusicBrainz::Server::Entity::Types;

no if $] >= 5.018, warnings => 'experimental::smartmatch';

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'SeriesType' };

sub entity_type { 'series' }

has ordering_type_id => (
    is => 'rw',
    isa => 'Int'
);

has ordering_type => (
    is => 'rw',
    isa => 'SeriesOrderingType'
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
