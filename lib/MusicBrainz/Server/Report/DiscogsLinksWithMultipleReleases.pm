package MusicBrainz::Server::Report::DiscogsLinksWithMultipleReleases;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::URLReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    q{
        SELECT
            r.id AS release_id, q.id AS url_id,
            row_number() OVER (ORDER BY q.count DESC, q.url, ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
            (
                SELECT
                    url.id, url.gid, url, COUNT(*) AS count
                FROM
                    url JOIN l_release_url lru ON lru.entity1 = url.id
                WHERE
                    url ~ E'^https?://www\\\\.discogs\\\\.com/'
                GROUP BY
                    url.id, url.gid, url HAVING COUNT(url) > 1
            ) AS q
            JOIN l_release_url lru ON lru.entity1 = q.id
            JOIN release r ON r.id = lru.entity0
            JOIN artist_credit ac ON r.artist_credit = ac.id
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

