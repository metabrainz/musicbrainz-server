package MusicBrainz::Server::Report::WikidataLinksWithMultipleEntities;
use Moose;

with 'MusicBrainz::Server::Report::URLReport';

sub query {
    my ($self) = @_;

    my @tables = $self->c->model('Relationship')->generate_table_list('url');

    my $inner_table = join(
        ' UNION ',
        map {<<~"EOSQL"} @tables
            SELECT link_type.id AS link_type_id, l_table.id AS rel_id, ${\$_->[1]} AS url
            FROM link_type
            JOIN link ON link.link_type = link_type.id
            JOIN ${\$_->[0]} l_table ON l_table.link = link.id
            EOSQL
    );

    my $query = <<~"EOSQL";
        SELECT url.id AS url_id, count(*) AS count, row_number() OVER (ORDER BY count(*) DESC, url.id DESC)
        FROM url JOIN ($inner_table) l ON l.url = url.id
        WHERE url.url LIKE 'https://www.wikidata.org%'
        GROUP BY url_id
        HAVING count(*) > 1
        EOSQL

    return $query
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
