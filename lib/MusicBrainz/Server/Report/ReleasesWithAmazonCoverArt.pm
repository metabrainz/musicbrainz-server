package MusicBrainz::Server::Report::ReleasesWithAmazonCoverArt;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    q(
        SELECT 
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM (
            SELECT release_coverart.id
            FROM release_coverart
            WHERE cover_art_url ~ '^https?://.*.images-amazon.com'
            AND NOT EXISTS (
                SELECT TRUE FROM cover_art_archive.cover_art ca
                JOIN cover_art_archive.cover_art_type cat ON ca.id = cat.id
                WHERE ca.release = release_coverart.id AND cat.type_id = 1
            )
          ) rca
        JOIN release r ON rca.id = r.id 
        JOIN artist_credit ac ON r.artist_credit = ac.id
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
