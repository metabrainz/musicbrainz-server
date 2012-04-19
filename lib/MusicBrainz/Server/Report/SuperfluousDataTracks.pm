package MusicBrainz::Server::Report::SuperfluousDataTracks;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data {
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, <<'EOSQL');
SELECT DISTINCT
  release.id, release.gid AS release_gid, release_name.name AS name,
  release.artist_credit AS artist_credit_id,
  musicbrainz_collate(release_name.name)
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
ORDER BY release.id DESC
EOSQL
}

sub template { 'report/superfluous_data_tracks.tt' }

1;
