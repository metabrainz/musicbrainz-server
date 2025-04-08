package MusicBrainz::Server::Report::SeriesContainingDuplicates;
use Moose;

use List::AllUtils qw( partition_by );
use MusicBrainz::Server::Constants qw( %PART_OF_SERIES );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::SeriesReport',
     'MusicBrainz::Server::Report::FilterForEditor::SeriesID';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $report_items = $self->$orig(@_);
    my %series_types = map {$_->id => $_} $self->c->model('SeriesType')->get_all();

    my %report_items_by_item_type = partition_by {
        $series_types{$_->{series}->{typeID}}->item_entity_type
    } @$report_items;

    my %entities_by_type;
    for my $item_type (keys %report_items_by_item_type) {
        my $model = $self->c->model(type_to_model($item_type));
        my @entity_ids = map { $_->{entity_id} } @{$report_items_by_item_type{$item_type}};
        $entities_by_type{$item_type} = $model->get_by_ids(@entity_ids);
    }

    for my $report_item (@$report_items) {
        my $entity_type = $series_types{$report_item->{series}->{typeID}}->item_entity_type;
        my $entity = $entities_by_type{$entity_type}{$report_item->{entity_id}};
        $report_item->{entity} = to_json_object($entity);
    }

    return $report_items;
};

sub query {
    my $self = shift;

    my @subqueries;

    my @series_l_tables = $self->c->model('Relationship')->generate_table_list(
        'series',
        keys %PART_OF_SERIES,
    );

    for my $series_l_table (@series_l_tables) {
        my (
            $table_name,
            $series_column,
            $other_column,
            $target_type,
        ) = @$series_l_table;

        my $part_of_series_gid = $self->c->sql->dbh->quote(
            $PART_OF_SERIES{$target_type},
        );

        my $subquery = <<~"SQL";
            SELECT
                DISTINCT s.id AS series_id,
                         rels_table.$other_column AS entity_id,
                         latv.text_value as order_number,
                         s.name AS series_name
            FROM
                series s
                JOIN $table_name rels_table ON rels_table.$series_column = s.id
                JOIN link ON link.id = rels_table.link
                JOIN link_type lt ON lt.id = link.link_type
                LEFT JOIN link_attribute_text_value latv ON latv.link = link.id
            WHERE (
                lt.gid = $part_of_series_gid -- part of series
                AND (
                    latv.attribute_type = 788 -- number attribute
                OR
                    latv.attribute_type IS NULL
                )
            )
            GROUP BY s.id, rels_table.$other_column, latv.text_value, s.name
            HAVING count(*) > 1
        SQL

        push @subqueries, $subquery;
    }

    my $inner_table = join(' UNION ', @subqueries);

    my $query = <<~"SQL";
        SELECT DISTINCT series_id,
                        entity_id,
                        order_number,
                        row_number() OVER (ORDER BY series_name COLLATE musicbrainz)
        FROM ($inner_table)
        SQL

    return $query;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

