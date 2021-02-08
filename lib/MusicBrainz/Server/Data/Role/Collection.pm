package MusicBrainz::Server::Data::Role::Collection;
use Moose::Role;

requires '_order_by', '_table', '_type', '_columns', '_new_from_row', 'c';

sub find_by_collection {
    my ($self, $collection_id, $limit, $offset, $order) = @_;

    my ($order_by, $extra_join, $also_select, $inner_order_by) = $self->_order_by($order);
    $extra_join //= '';
    $inner_order_by //= $order_by;

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
        ORDER BY id, $inner_order_by
      ) $type
      ORDER BY $order_by, id";

    $self->query_to_list_limited($query, [$collection_id], $limit, $offset);
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

