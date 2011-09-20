package MusicBrainz::Server::Report::TracksNamedWithSequence;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data {
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, <<'EOSQL');
SELECT DISTINCT release_name.name, release.id, release.gid,
                release.artist_credit AS artist_credit_id,
                release.edits_pending,
                musicbrainz_collate(release_name.name)
FROM track
JOIN track_name tname ON tname.id = track.name
JOIN medium ON track.tracklist = medium.tracklist
JOIN release ON medium.release = release.id
JOIN release_name ON release.name = release_name.id
WHERE tname.name ~ '^[0-9]'
AND   tname.name ~ ('^0*' || track.position || '[^0-9]')
ORDER BY musicbrainz_collate(release_name.name)
EOSQL
}

sub template { 'report/tracks_named_with_sequence.tt' }

1;
