package MusicBrainz::Server::Report::RecordingsWithEarliestReleaseRelationships;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    "
        SELECT
            r.id AS recording_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM (
            SELECT
                entity0 AS entity, link
            FROM
                l_recording_recording
            UNION
            SELECT
                entity1 AS entity, link
            FROM
                l_recording_recording
        ) AS lrr
            JOIN link ON link.id = lrr.link
            JOIN link_type ON link.link_type = link_type.id
            JOIN recording r ON lrr.entity = r.id
            JOIN artist_credit ac ON r.artist_credit = ac.id
        WHERE
            link_type.name = 'first track release'
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
