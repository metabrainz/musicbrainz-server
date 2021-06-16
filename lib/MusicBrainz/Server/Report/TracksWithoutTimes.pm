package MusicBrainz::Server::Report::TracksWithoutTimes;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    <<~'EOSQL'
    SELECT release.id AS release_id,
        row_number() OVER (ORDER BY release.name COLLATE musicbrainz)
    FROM (
        SELECT release.id
        FROM track
        JOIN medium ON track.medium = medium.id
        JOIN release ON medium.release = release.id
        WHERE track.length is null
        GROUP BY release.id
    ) s
    JOIN release ON s.id = release.id
    EOSQL
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
