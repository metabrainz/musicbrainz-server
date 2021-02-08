package MusicBrainz::Server::Entity::AggregatedTag;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'tag_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'tag' => (
    is => 'rw',
    isa => 'Tag'
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
        tag => $self->tag->TO_JSON,
        count => $self->count,
    };
}
__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Entity::AggregatedTag

=head1 ATTRIBUTES

=head2 tag_id, tag

The tag.

=head2 count

How many times was the tag used.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
