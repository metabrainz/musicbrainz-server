package MusicBrainz::Server::Report::ISRCsWithManyRecordings;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub table { 'isrc_with_many_recordings' }

sub query {
    "
        SELECT i.isrc, recordingcount, r.id as recording_id, r.name, r.length,
          row_number() OVER (ORDER BY i.isrc)
        FROM isrc i
          JOIN recording r ON (r.id = i.recording)
          JOIN (
           SELECT isrc, count(*) AS recordingcount
            FROM isrc
            GROUP BY isrc HAVING count(*) > 1
          ) t ON t.isrc = i.isrc
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
