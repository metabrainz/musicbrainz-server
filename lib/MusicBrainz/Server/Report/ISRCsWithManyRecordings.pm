package MusicBrainz::Server::Report::ISRCsWithManyRecordings;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub table { 'isrc_with_many_recordings' }
sub component_name { 'IsrcsWithManyRecordings' }

sub query {
    '
        SELECT i.isrc, recordingcount, r.id AS recording_id, r.name, r.length,
          row_number() OVER (ORDER BY i.isrc)
        FROM isrc i
          JOIN recording r ON (r.id = i.recording)
          JOIN (
           SELECT isrc, count(*) AS recordingcount
            FROM isrc
            GROUP BY isrc HAVING count(*) > 1
          ) t ON t.isrc = i.isrc
    ';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
