package MusicBrainz::Server::Report::SeriesContainingDuplicates;
use Moose;

use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::SeriesReport',
     'MusicBrainz::Server::Report::FilterForEditor::SeriesID';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    for my $result (@$items) {
        my $series = $result->{series};
        my $series_type = $self->c->model('SeriesType')->get_by_id($series->{typeID});
        my $entity_type = $series_type->item_entity_type;
        my $model = $self->c->model(type_to_model($entity_type));
        my $entity = $model->get_by_id($result->{entity_id});
        $result->{entity} = to_json_object($entity);
    }
    my $entities = $self->c->model('Series')->get_by_ids(
        map { $_->{series_id} } @$items,
    );

    return $items;
};

sub query {
    q{
        SELECT
            DISTINCT s.id AS series_id,
                     las.entity0 AS entity_id,
                     latv.text_value,
            row_number() OVER (ORDER BY s.name COLLATE musicbrainz)
        FROM
            series s
            JOIN l_artist_series las ON las.entity1 = s.id
            JOIN link ON link.id = las.link
            JOIN link_type lt ON lt.id = link.link_type
            LEFT JOIN link_attribute_text_value latv ON latv.link = link.id
        WHERE (
            lt.gid = 'd1a845d1-8c03-3191-9454-e4e8d37fa5e0' -- part of series
            AND (
                latv.attribute_type = 788 -- number attribute
            OR
                latv.attribute_type IS NULL
            )
        )
        GROUP BY s.id, las.entity0, latv.text_value
        HAVING count(*) > 1
    };
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

