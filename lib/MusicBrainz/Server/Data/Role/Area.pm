package MusicBrainz::Server::Data::Role::Area;
use Moose::Role;
use MusicBrainz::Server::Constants qw( $SPAMMER_FLAG );
use MusicBrainz::Server::Data::Utils qw( get_area_containment_join );

requires '_columns', '_table', '_area_columns';

sub find_by_area {
    my ($self, $area_id, $limit, $offset) = @_;

    my @area_cols = @{ $self->_area_columns };
    my $area_cols_condition = @area_cols > 1
        ? (' IN (' . join(q(, ), @area_cols) . ')')
        : (' = ' . $area_cols[0]);
    my $area_containment_join = get_area_containment_join($self->sql);
    my $table = $self->can('_find_by_area_table') ? $self->_find_by_area_table : $self->_table;
    my $columns = $self->_columns;
    my $order_by = $self->can('_find_by_area_order') ? $self->_find_by_area_order : 'name, id';
    my $extra_conditions = '';

    if ($table eq 'editor') {
        $extra_conditions = " AND (editor.privs & $SPAMMER_FLAG) = 0";
    }

    my $query = <<~SQL;
        SELECT $columns
          FROM $table
         WHERE \$1 $area_cols_condition
               $extra_conditions
         UNION
        SELECT $columns
          FROM $table
          JOIN $area_containment_join ac ON ac.descendant $area_cols_condition
         WHERE ac.parent = \$1
               $extra_conditions
         ORDER BY $order_by
        SQL

    $self->query_to_list_limited(
        $query, [$area_id], $limit, $offset, undef,
        dollar_placeholders => 1,
    );
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

