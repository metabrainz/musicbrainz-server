package MusicBrainz::Server::Report::SuperfluousDataTracks;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport';

sub query {
    <<'EOSQL'
SELECT DISTINCT
  release.id AS release_id,
  row_number() OVER (ORDER BY release.id DESC)
FROM release
JOIN release_name ON release_name.id = release.name
JOIN medium ON medium.release = release.id
LEFT JOIN medium_format ON medium.format = medium_format.id
JOIN tracklist ON medium.tracklist = tracklist.id
JOIN track ON tracklist.id = track.tracklist
JOIN track_name ON track_name.id = track.name
WHERE (medium_format.has_discids = TRUE OR medium_format.has_discids IS NULL)
AND track.position = tracklist.track_count
AND track_name.name ~* E'([[:<:]](dat(a|en)|cccd|gegevens|video)[[:>:]]|\\u30C7\\u30FC\\u30BF)'
AND NOT EXISTS (
   SELECT TRUE FROM medium_cdtoc WHERE medium_cdtoc.medium = medium.id
   LIMIT 1
)
EOSQL
}

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
