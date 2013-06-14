package MusicBrainz::Server::Report::TracksWithoutTimes;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    <<'EOSQL'
SELECT release.id AS release_id,
  row_number() OVER (ORDER BY musicbrainz_collate(release_name.name))
FROM (
  SELECT release.id
  FROM track
  JOIN medium ON track.medium = medium.id
  JOIN release ON medium.release = release.id
  JOIN release_name ON release.name = release_name.id
  WHERE track.length is null
  GROUP BY release.id
) s
JOIN release ON s.id = release.id
JOIN release_name ON release_name.id = release.name
EOSQL
}

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
