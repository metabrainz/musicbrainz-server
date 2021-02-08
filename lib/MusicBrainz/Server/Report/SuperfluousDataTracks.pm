package MusicBrainz::Server::Report::SuperfluousDataTracks;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    <<'EOSQL'
SELECT
  release.id AS release_id,
  row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, release.name COLLATE musicbrainz)
FROM (
   SELECT DISTINCT release.* FROM release
   JOIN medium ON medium.release = release.id
   LEFT JOIN medium_format ON medium.format = medium_format.id
   JOIN track ON track.medium = medium.id
   WHERE (medium_format.has_discids = TRUE OR medium_format.has_discids IS NULL)
     AND track.position = medium.track_count
     AND track.name ~* E'([[:<:]](dat(a|en)|cccd|gegevens|video)[[:>:]]|\\u30C7\\u30FC\\u30BF)'
     AND track.is_data_track = FALSE
     AND NOT EXISTS (
       SELECT TRUE FROM medium_cdtoc WHERE medium_cdtoc.medium = medium.id
       LIMIT 1
     )
) release
JOIN artist_credit ac ON release.artist_credit = ac.id
EOSQL
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
