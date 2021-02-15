package MusicBrainz::Server::Report::RecordingsWithVaryingTrackLengths;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    "
        SELECT
            q.id AS recording_ID,
            row_number() OVER (ORDER BY q.aname COLLATE musicbrainz, q.rname COLLATE musicbrainz)
        FROM (
            SELECT DISTINCT
                r.id,
                ac.name AS aname,
                r.name AS rname
            FROM
                recording r
                JOIN track t0 ON t0.recording = r.id
                JOIN track t1 ON t1.recording = r.id
                JOIN artist_credit ac ON r.artist_credit = ac.id
            WHERE
                t0.id != t1.id
                AND @(t0.length - t1.length) > 30000
        ) AS q
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
