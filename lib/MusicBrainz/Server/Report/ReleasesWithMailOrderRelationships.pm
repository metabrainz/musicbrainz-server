package MusicBrainz::Server::Report::ReleasesWithMailOrderRelationships;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    '
        SELECT
            DISTINCT r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
            release r
            JOIN artist_credit ac ON r.artist_credit = ac.id
        WHERE EXISTS (
            SELECT TRUE
            FROM medium
            WHERE medium.release = r.id
              AND medium.format = 12 -- there is one digital medium
        ) AND NOT EXISTS (
            SELECT TRUE
            FROM medium
            WHERE medium.release = r.id
              AND medium.format != 12 -- all mediums should be digital
        ) AND EXISTS (
            SELECT TRUE
            FROM
                l_release_url lru
                JOIN link ON lru.link = link.id
            WHERE lru.entity0 = r.id 
              AND link.link_type = 79 -- mail order
        )
    ';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
