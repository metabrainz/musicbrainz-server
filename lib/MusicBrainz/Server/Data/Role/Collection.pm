package MusicBrainz::Server::Data::Role::Collection;
use Moose::Role;

requires '_order_by', '_table', '_type', '_columns', '_new_from_row', 'c';

use MusicBrainz::Server::Data::Utils qw( order_by );
use MusicBrainz::Server::Entity::CollectionItem;

sub find_by_collection {
    my ($self, $collection_id, $limit, $offset, $order) = @_;

    my ($order_by, $extra_join, $also_select) = $self->_order_by($order);
    $extra_join //= '';

    my $table = $self->_table;
    my $type = $self->_type;

    my $query = "
      SELECT *
      FROM (
      SELECT DISTINCT ON (" . $self->_id_column . ")
        " . $self->_columns .
          ($also_select ? ", $also_select" : "") . "
        FROM $table
        JOIN editor_collection_$type ec ON " . $self->_id_column . " = ec.$type
        $extra_join
        WHERE ec.collection = ?
        ORDER BY id
      ) $type
      ORDER BY $order_by";

    $self->query_to_list_limited($query, [$collection_id], $limit, $offset);
}

sub find_items_by_collection {
    my ($self, $collection_id, $limit, $offset, $order) = @_;

    my ($order_by, $extra_join, $also_select) = $self->_order_collection_items_by($order);
    $extra_join //= '';

    my $table = $self->_table;
    my $type = $self->_type;

    my $query = "
      SELECT *
      FROM (
      SELECT DISTINCT ON (" . $self->_id_column . ")
        " . $self->_columns .
          ($also_select ? ", $also_select" : "") . "
        , ec.added AS collection_item_added
        FROM $table
        JOIN editor_collection_$type ec ON " . $self->_id_column . " = ec.$type
        $extra_join
        WHERE ec.collection = ?
        ORDER BY id
      ) $type
      ORDER BY $order_by";

    $self->query_to_list_limited(
        $query,
        [$collection_id],
        $limit,
        $offset,
        $self->_new_collection_item_from_row);
}

sub _order_collection_items_by {
    my ($self, $order) = @_;

    my ($order_by, $extra_join, $also_select) = $self->_order_by($order);

    my $collection_items_ordering_map = {
        'added' => sub {
            return 'collection_item_added'
        },
    };

    my $absolute_order = $order;
    $absolute_order =~ s/^-// if defined $absolute_order;
    if (defined $absolute_order &&
      exists $collection_items_ordering_map->{$absolute_order}) {
      $order_by = order_by($order, 'added', $collection_items_ordering_map);
    }

    return ($order_by, $extra_join, $also_select);
}

sub _new_collection_item_from_row {
    my ($self, $row) = @_;
    return unless $row;

    return MusicBrainz::Server::Entity::CollectionItem->new(
        entity => $self->_new_from_row($row),
        added => $row->{collection_item_added}
    );
}

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2015 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

