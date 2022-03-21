package MusicBrainz::Server::Entity::AggregatedGenre;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'genre_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'genre' => (
    is => 'rw',
    isa => 'Genre',
);

has 'entity_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'entity' => (
    is => 'rw',
    isa => 'Object'
);

has 'count' => (
    is => 'rw',
    isa => 'Int'
);

sub TO_JSON {
    my ($self) = @_;

    return {
        genre => $self->genre->TO_JSON,
        count => $self->count,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 NAME

MusicBrainz::Server::Entity::AggregatedGenre

=head1 ATTRIBUTES

=head2 genre_id, genre

The genre.

=head2 count

How many times was the genre used.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
