package MusicBrainz::Server::Report::ASINsWithMultipleReleases;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::URLReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub table { 'asins_with_multiple_releases' }
sub component_name { 'AsinsWithMultipleReleases' }

sub query {
    "   SELECT r.id AS release_id, q.id AS url_id,
          row_number() OVER (
             ORDER BY q.count DESC, q.url,
               musicbrainz_collate(ac.name), musicbrainz_collate(r.name)
          )
        FROM
            (
                SELECT
                    url.id, url.gid, url, COUNT(*) AS count
                FROM
                    url JOIN l_release_url lru ON lru.entity1 = url.id
                WHERE
                    url ~ E'^https?://www\\\\.amazon\\\\.[^/]+/'
                GROUP BY
                    url.id, url.gid, url HAVING COUNT(url) > 1
            ) AS q
            JOIN l_release_url lru ON lru.entity1 = q.id
            JOIN release r ON r.id = lru.entity0
            JOIN artist_credit ac ON r.artist_credit = ac.id";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

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
