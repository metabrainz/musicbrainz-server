package MusicBrainz::Server::Report::SuperfluousDataTracks;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    <<'EOSQL'
SELECT
  release.id AS release_id,
  row_number() OVER (ORDER BY musicbrainz_collate(an.name), musicbrainz_collate(release_name.name))
FROM (
   SELECT DISTINCT release.* FROM release
   JOIN medium ON medium.release = release.id
   LEFT JOIN medium_format ON medium.format = medium_format.id
   JOIN track ON track.medium = medium.id
   JOIN track_name ON track_name.id = track.name
   WHERE (medium_format.has_discids = TRUE OR medium_format.has_discids IS NULL)
     AND track.position = medium.track_count
     AND track_name.name ~* E'([[:<:]](dat(a|en)|cccd|gegevens|video)[[:>:]]|\\u30C7\\u30FC\\u30BF)'
     AND NOT EXISTS (
       SELECT TRUE FROM medium_cdtoc WHERE medium_cdtoc.medium = medium.id
       LIMIT 1
     )
) release
JOIN release_name ON release_name.id = release.name
JOIN artist_credit ac ON release.artist_credit = ac.id
JOIN artist_name an ON ac.name = an.id
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
