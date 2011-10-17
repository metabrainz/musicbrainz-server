package MusicBrainz::Server::Report::TracksWithSequenceIssues;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Report';

sub gather_data
{
	my ($self, $writer) = @_;

    # There are 3 checks going on in this query:
    # 1. The first track should be '1'
    # 2. The last track should match the amount of tracks
    # 3. The sum of all tracks should match a standard arithmetic progression.
    #    This is used to ensure that the list of track positions is linear,
    #    has no gaps, and no duplicates.
    #    E.g. If the tracklist had tracks: 1, 2, 3, 3, 5 then
    #    the following will *not* hold:
    #    1 + 2 + 3 + 3 + 5 = 1 + 2 + 3 + 4 + 5
	$self->gather_data_from_query($writer, <<'EOSQL');
SELECT DISTINCT release.id, release.gid, release.artist_credit AS artist_credit_id,
  musicbrainz_collate(rel_name.name), rel_name.name
FROM (
    SELECT
      track.tracklist,
      min(track.position) AS first_track,
      max(track.position) AS last_track,
      count(track.position) AS track_count,
      sum(track.position) AS track_pos_acc
    FROM
      track
    GROUP BY track.tracklist
) s
JOIN medium ON medium.tracklist = s.tracklist
JOIN release ON release.id = medium.release
JOIN release_name rel_name ON rel_name.id = release.name
WHERE
     first_track != 1
  OR last_track != track_count
  OR (track_count * (1 + track_count)) / 2 <> track_pos_acc
ORDER BY musicbrainz_collate(rel_name.name)
EOSQL
}

sub post_load {
    my ($self, $items) = @_;
    for my $item (@$items) {
        $item->{release} = MusicBrainz::Server::Data::Release->_new_from_row($item)
    }

    $self->c->model('ArtistCredit')->load(map { $_->{release} } @$items);
}

sub template {
    return 'report/tracks_with_sequence_issues.tt'
}

1;
