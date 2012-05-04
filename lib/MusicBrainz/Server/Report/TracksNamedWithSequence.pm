package MusicBrainz::Server::Report::TracksNamedWithSequence;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data {
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, <<'EOSQL');
SELECT release.id, release.gid AS release_gid,
       release.artist_credit AS artist_credit_id,
       release.edits_pending,
       release_name.name
FROM (
  SELECT release.id
  FROM track
  JOIN track_name tname ON tname.id = track.name
  JOIN medium ON track.tracklist = medium.tracklist
  JOIN release ON medium.release = release.id
  JOIN release_name ON release.name = release_name.id
  WHERE tname.name ~ '^[0-9]'
  AND   tname.name ~ ('^0*' || track.position || '[^0-9]')
  GROUP BY release.id
  HAVING count(*) > 2
) s
JOIN release ON s.id = release.id
JOIN release_name ON release_name.id = release.name
ORDER BY musicbrainz_collate(release_name.name)
EOSQL
}

sub template { 'report/tracks_named_with_sequence.tt' }

1;
