package MusicBrainz::Server::Report::RecordingTrackDifferentName;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    "
        SELECT
            r.id AS recording_id, t.name AS track_name,
            row_number() OVER (ORDER BY r.name COLLATE musicbrainz, t.name COLLATE musicbrainz)
        FROM
            recording r
            JOIN track t 
            ON r.id = t.recording
        WHERE (SELECT COUNT(*) FROM track WHERE recording = r.id) = 1
          AND r.name != t.name
    "
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
