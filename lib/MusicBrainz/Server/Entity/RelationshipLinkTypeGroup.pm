package MusicBrainz::Server::Entity::RelationshipLinkTypeGroup;

use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( add_linked_entity );

has 'link_type_id' => (
    is => 'ro',
    isa => 'Int',
);

has 'link_type' => (
    is => 'rw',
    isa => 'Maybe[LinkType]',
);

has 'direction' => (
    is => 'ro',
    isa => 'Int',
);

has 'relationships' => (
    is => 'rw',
    isa => 'ArrayRef[Relationship]',
    default => sub { [] },
    lazy => 1,
    traits => ['Array'],
    handles => {
        all_relationships => 'elements',
        add_relationship => 'push',
    },
);

has 'is_loaded' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'total_relationships' => (
    is => 'ro',
    isa => 'Int',
    default => 0,
);

has 'limit' => (
    is => 'ro',
    isa => 'Int',
    default => 25,
);

has 'offset' => (
    is => 'ro',
    isa => 'Int',
    default => 0,
);

sub TO_JSON {
    my ($self) = @_;

    my $link_type_id = $self->link_type_id + 0;
    my $direction =
        ($self->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD)
            ? 'backward' : 'forward';
    my $is_loaded = boolean_to_json($self->is_loaded);
    my $total_relationships = $self->total_relationships + 0;
    my $limit = $self->limit + 0;
    my $offset = $self->offset + 0;

    my $link_type = $self->link_type;
    add_linked_entity('link_type', $link_type_id, $link_type);

    return {
        link_type_id => $link_type_id,
        direction => $direction,
        relationships => [map { $_->TO_JSON } $self->all_relationships],
        is_loaded => $is_loaded,
        total_relationships => $total_relationships,
        limit => $limit,
        offset => $offset,
    };
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
