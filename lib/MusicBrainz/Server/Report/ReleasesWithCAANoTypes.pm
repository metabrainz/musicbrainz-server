package MusicBrainz::Server::Report::ReleasesWithCAANoTypes;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub component_name { 'ReleasesWithCaaNoTypes' }
sub query {
    '
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM (
            SELECT DISTINCT r.*
            FROM release r
            WHERE EXISTS (
            SELECT 1 FROM cover_art_archive.cover_art WHERE cover_art.release = r.id
            )
            AND NOT EXISTS (
            SELECT 1 FROM cover_art_archive.cover_art_type JOIN cover_art_archive.cover_art ON cover_art_type.id = cover_art.id WHERE cover_art.release = r.id
        )
        ) r
        JOIN artist_credit ac ON r.artist_credit = ac.id
    ';
}

sub table { 'releases_with_caa_no_types' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018(s) MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
