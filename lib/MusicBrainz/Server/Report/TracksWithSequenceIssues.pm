package MusicBrainz::Server::Report::TracksWithSequenceIssues;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    # There are 3 checks going on in this query:
    # 1. The first track should be '1' or possibly '0' (pre-gap track).
    # 2. The last track should match the amount of tracks (minus 1 if there's
    #    a pregap track 0).
    # 3. The sum of all tracks should match a standard arithmetic progression.
    #    This is used to ensure that the list of track positions is linear,
    #    has no gaps, and no duplicates.
    #    E.g. If the tracklist had tracks: 1, 2, 3, 3, 5 then
    #    the following will *not* hold:
    #    1 + 2 + 3 + 3 + 5 = 1 + 2 + 3 + 4 + 5
    <<~'EOSQL'
    SELECT release.id AS release_id,
      row_number() OVER (ORDER BY release.name COLLATE musicbrainz)
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
        (first_track <> 1 AND first_track <> 0)
        OR last_track <> s.track_count - (1 - first_track)
        OR (last_track * (1 + last_track)) <> 2 * track_pos_acc
    ) release
    EOSQL
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
