package MusicBrainz::Server::Report::RecordingsSameNameDifferentArtistsSameName;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    "
    SELECT
        recording_id,
        row_number() OVER (ORDER BY musicbrainz_collate(rname), recording_id)
    FROM (
        SELECT
            DISTINCT r1.id AS recording_id, r1.NAME AS rname, a1.NAME AS aname
        FROM
            recording r1
            INNER JOIN recording r2 ON (r1.NAME = r2.NAME AND r1.id != r2.id)
            INNER JOIN artist_credit_name acn1 ON r1.artist_credit = acn1.artist_credit
            INNER JOIN artist_credit_name acn2 ON r2.artist_credit = acn2.artist_credit
            INNER JOIN artist a1 ON acn1.artist = a1.id
            INNER JOIN artist a2 ON (acn2.artist = a2.id AND a1.NAME = a2.NAME AND a1.id != a2.id)
    ) r
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
