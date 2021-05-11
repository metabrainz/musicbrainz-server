package MusicBrainz::Server::Report::ReleasesWithEmptyMediums;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport';
with 'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    q{
        SELECT
            DISTINCT r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
            release r
            JOIN artist_credit ac ON r.artist_credit = ac.id
        WHERE EXISTS (
            SELECT 1
            FROM medium m
            WHERE m.release = r.id
            AND NOT EXISTS (
              SELECT 1
              FROM track t
              WHERE t.medium = m.id
              LIMIT 1
            )
            LIMIT 1
        )
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
