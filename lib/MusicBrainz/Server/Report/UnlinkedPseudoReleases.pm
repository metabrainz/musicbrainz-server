package MusicBrainz::Server::Report::UnlinkedPseudoReleases;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
SELECT r.id AS release_id,
  row_number() OVER (ORDER BY musicbrainz_collate(ac.name), musicbrainz_collate(r.name))
FROM release r
        JOIN release_status rs ON r.status = rs.id
        LEFT JOIN l_release_release lrr ON r.id = lrr.entity1
        LEFT JOIN link l ON lrr.link = l.id AND l.link_type IN (
                SELECT lt.id
                FROM link_type lt
                WHERE lt.name='transl-tracklisting'
        )
        JOIN artist_credit ac ON r.artist_credit = ac.id
WHERE r.status IN (
        SELECT rs.id
        FROM release_status rs
        WHERE rs.name = 'Pseudo-Release'
) AND lrr.link IS NULL
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2012 Calvin Walton
Based on code (C) 2009 Lukas Lalinsky

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
