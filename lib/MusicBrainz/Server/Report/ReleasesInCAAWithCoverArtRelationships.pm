package MusicBrainz::Server::Report::ReleasesInCAAWithCoverArtRelationships;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY musicbrainz_collate(ac.name), musicbrainz_collate(r.name))
        FROM (
            SELECT DISTINCT r.*
            FROM release r
            JOIN cover_art_archive.cover_art ON cover_art.release = r.id
            JOIN l_release_url lru ON entity0 = r.id
            JOIN link l ON l.id = lru.link
            JOIN link_type lt ON lt.id = l.link_type
            WHERE lt.gid = '2476be45-3090-43b3-a948-a8f972b4065c'
            AND lru.edits_pending = 0
        ) r
        JOIN artist_credit ac ON r.artist_credit = ac.id
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

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
