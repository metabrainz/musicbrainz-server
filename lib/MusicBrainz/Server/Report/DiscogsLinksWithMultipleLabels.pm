package MusicBrainz::Server::Report::DiscogsLinksWithMultipleLabels;

use utf8;

use Moose;

with 'MusicBrainz::Server::Report::LabelReport',
     'MusicBrainz::Server::Report::URLReport',
     'MusicBrainz::Server::Report::FilterForEditor::LabelID';

sub query {
    "
        SELECT
            l.id AS label_id, q.id AS url_id,
            row_number() OVER (ORDER BY q.count DESC, q.url, l.name COLLATE musicbrainz)
        FROM
            (
                SELECT
                    url.id, url.gid, url, COUNT(*) AS count
                FROM
                    url JOIN l_label_url llu ON llu.entity1 = url.id
                WHERE
                    url ~ E'^https?://www\\\\.discogs\\\\.com/'
                GROUP BY
                    url.id, url.gid, url HAVING COUNT(url) > 1
            ) AS q
            JOIN l_label_url llu ON llu.entity1 = q.id
            JOIN label l ON l.id = llu.entity0
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2012 Johannes Weißl
Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
