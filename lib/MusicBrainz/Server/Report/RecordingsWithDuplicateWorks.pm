package MusicBrainz::Server::Report::RecordingsWithDuplicateWorks;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {<<~'SQL'}
    SELECT DISTINCT ON (r.id)
        r.id AS recording_id,
        row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
    FROM recording r
    JOIN artist_credit ac ON ac.id = r.artist_credit
    JOIN l_recording_work lrw1 ON lrw1.entity0 = r.id
    JOIN l_recording_work lrw2 ON lrw2.entity0 = r.id
    JOIN work w1 ON w1.id = lrw1.entity1
    JOIN work w2 ON w2.id = lrw2.entity1
    WHERE lrw2.id > lrw1.id
    AND w1.name = w2.name
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
