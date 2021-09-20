package MusicBrainz::Server::Report::LinksWithMultipleEntities;
use Moose;

with 'MusicBrainz::Server::Report::URLReport';

sub query {
    my ($self) = @_;

    my @tables = $self->c->model('Relationship')->generate_table_list('url');

    my $inner_table = join(
        ' UNION ',
        map {<<~"SQL"} @tables
            SELECT DISTINCT ON (url, other_entity) -- ignore several rel types between same entity pair
                link_type.id AS link_type_id, link_type.gid AS link_type_gid,
                l_table.id AS rel_id, ${\$_->[1]} AS url, ${\$_->[2]} AS other_entity
            FROM link_type
            JOIN link ON link.link_type = link_type.id
            JOIN ${\$_->[0]} l_table ON l_table.link = link.id
            SQL
    );

    my $query = <<~"SQL";
        SELECT url.id AS url_id, count(*) AS count, row_number() OVER (ORDER BY count(*) DESC, url.id DESC)
        FROM url JOIN ($inner_table) l ON l.url = url.id
        WHERE url.url NOT LIKE 'https://www.wikidata.org%' -- has its own report
        AND url.url NOT LIKE 'https://www.discogs.com%' -- has its own report set
        AND l.link_type_gid != '4f2e710d-166c-480c-a293-2e2c8d658d87' -- release ASINs have their own report
        AND l.link_type_gid NOT IN ('004bd0c3-8a45-4309-ba52-fa99f3aa3d50', 'f25e301d-b87b-4561-86a0-5d2df6d26c0a') -- licenses are meant for reuse
        GROUP BY url_id
        HAVING count(*) > 1
        SQL

    return $query
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
