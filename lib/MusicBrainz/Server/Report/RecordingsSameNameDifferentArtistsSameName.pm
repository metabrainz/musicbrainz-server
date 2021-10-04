package MusicBrainz::Server::Report::RecordingsSameNameDifferentArtistsSameName;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

# MBS-10843: This report has been disabled since the upgrade to PG 12,
# because its query can no longer execute in under 5 minutes in
# production.

sub query {
    '
    SELECT
        recording_id,
        row_number() OVER (ORDER BY rname COLLATE musicbrainz, artist_id)
    FROM (
        SELECT
            DISTINCT r1.id AS recording_id, r1.name AS rname, a1.id as artist_id
        FROM
            recording r1
            JOIN recording r2 ON (r1.name = r2.name AND r1.id != r2.id)
            JOIN artist_credit ac1 ON (r1.artist_credit = ac1.id AND ac1.artist_count = 1)
            JOIN artist_credit ac2 ON (r2.artist_credit = ac2.id AND ac2.artist_count = 1)
            JOIN artist_credit_name acn1 ON ac1.id = acn1.artist_credit
            JOIN artist_credit_name acn2 ON ac2.id = acn2.artist_credit
            JOIN artist a1 ON acn1.artist = a1.id
            JOIN artist a2 ON (acn2.artist = a2.id AND a1.id != a2.id)
            WHERE (acn1.name = acn2.name OR a1.name = a2.name)
    ) r
    ';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
