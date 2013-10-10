package MusicBrainz::Server::Report::SingleMediumReleasesWithMediumTitles;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
   "SELECT DISTINCT ON (release.id)
      release.id AS release_id,
      row_number() OVER (
        ORDER BY musicbrainz_collate(an.name), musicbrainz_collate(rn.name)
      )
    FROM release
    JOIN medium ON release.id = medium.release
    JOIN artist_credit ON release.artist_credit = artist_credit.id
    JOIN artist_name an ON an.id = artist_credit.name
    JOIN release_name rn ON release.name = rn.id
    WHERE release.id IN (
      SELECT release
      FROM medium
      GROUP BY release
      HAVING count(id) = 1
    ) AND medium.name != ''";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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

