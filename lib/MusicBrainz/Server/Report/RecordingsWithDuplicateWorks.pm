package MusicBrainz::Server::Report::RecordingsWithDuplicateWorks;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {<<~'SQL'}
    SELECT
        r.id AS recording_id,
        row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
    FROM recording r
    JOIN artist_credit ac ON ac.id = r.artist_credit
    WHERE EXISTS (
        SELECT work.name
        FROM l_recording_work lrw
        JOIN work ON lrw.entity1 = work.id
        WHERE lrw.entity0 = r.id
        GROUP BY work.name HAVING COUNT(*) > 1
    )
SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
