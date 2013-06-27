package MusicBrainz::Server::Report::RecordingsWithVaryingTrackLengths;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    "
        SELECT
            q.id AS recording_ID,
            row_number() OVER (ORDER BY musicbrainz_collate(q.aname), musicbrainz_collate(q.rname))
        FROM (
            SELECT DISTINCT
                r.id,
                an.name AS aname,
                rn.name AS rname
            FROM
                recording r
                JOIN track t0 ON t0.recording = r.id
                JOIN track t1 ON t1.recording = r.id
                JOIN track_name rn ON r.name = rn.id
                JOIN artist_credit ac ON r.artist_credit = ac.id
                JOIN artist_name an ON ac.name = an.id
            WHERE
                t0.id != t1.id
                AND @(t0.length - t1.length) > 30000
        ) AS q
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
