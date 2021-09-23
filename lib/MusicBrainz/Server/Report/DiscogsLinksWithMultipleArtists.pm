package MusicBrainz::Server::Report::DiscogsLinksWithMultipleArtists;

use utf8;

use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::URLReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    q{
        SELECT
            a.id AS artist_id, q.id AS url_id, q.count,
            row_number() OVER (ORDER BY q.count DESC, q.url, a.name COLLATE musicbrainz)
        FROM
            (
                SELECT
                    url.id, url.gid, url, COUNT(*) AS count
                FROM
                    url JOIN l_artist_url lau ON lau.entity1 = url.id
                WHERE
                    url ~ E'^https?://www\\\\.discogs\\\\.com/'
                GROUP BY
                    url.id, url.gid, url HAVING COUNT(url) > 1
            ) AS q
            JOIN l_artist_url lau ON lau.entity1 = q.id
            JOIN artist a ON a.id = lau.entity0
    };
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
