package MusicBrainz::Server::Entity::RelationshipTargetTypeGroup;

use Moose;
use MooseX::Types::Moose qw( Str );
use MooseX::Types::Structured qw( Map );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use aliased 'MusicBrainz::Server::Entity::RelationshipLinkTypeGroup';

has 'link_type_groups' => (
    is => 'rw',
    # Keys are in the form "$link_type_id:$source_column",
    # where $source_column is either entity0 or entity1.
    isa => Map[Str, RelationshipLinkTypeGroup],
    default => sub { +{} },
    lazy => 1,
);

sub all_relationships {
    map { $_->all_relationships } values %{ shift->link_type_groups }
}

sub TO_JSON {
    my $self = shift;

    my %link_type_groups = %{ $self->link_type_groups };

    my %json = map {
        $_ => to_json_object($link_type_groups{$_})
    } keys %link_type_groups;

    return \%json;
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
