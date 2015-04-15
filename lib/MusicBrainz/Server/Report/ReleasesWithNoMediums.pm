package MusicBrainz::Server::Report::ReleasesWithNoMediums;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport';
with 'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    q{
        SELECT
            DISTINCT r.id AS release_id,
            row_number() OVER (ORDER BY musicbrainz_collate(ac.name), musicbrainz_collate(r.name))
        FROM
            release r
            JOIN artist_credit ac ON r.artist_credit = ac.id
        WHERE NOT EXISTS (
            SELECT 1 FROM medium m WHERE m.release = r.id LIMIT 1
        )
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
