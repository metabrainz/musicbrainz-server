package MusicBrainz::Server::Report::TracksWithSequenceIssues;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    # There are 3 checks going on in this query:
    # 1. The first track should be '1'
    # 2. The last track should match the amount of tracks
    # 3. The sum of all tracks should match a standard arithmetic progression.
    #    This is used to ensure that the list of track positions is linear,
    #    has no gaps, and no duplicates.
    #    E.g. If the tracklist had tracks: 1, 2, 3, 3, 5 then
    #    the following will *not* hold:
    #    1 + 2 + 3 + 3 + 5 = 1 + 2 + 3 + 4 + 5
    <<'EOSQL'
SELECT release.id AS release_id,
  row_number() OVER (ORDER BY musicbrainz_collate(rel_name.name))
FROM
(
  SELECT DISTINCT release.*
  FROM
    ( SELECT
        track.medium,
        min(track.position) AS first_track,
        max(track.position) AS last_track,
        count(track.position) AS track_count,
        sum(track.position) AS track_pos_acc
      FROM
        track
      GROUP BY track.medium
   ) s
   JOIN medium ON medium.id = s.medium
   JOIN release ON release.id = medium.release
   WHERE
     first_track != 1
     OR last_track != s.track_count
     OR (s.track_count * (1 + s.track_count)) / 2 <> track_pos_acc
) release
JOIN release_name rel_name ON rel_name.id = release.name
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
