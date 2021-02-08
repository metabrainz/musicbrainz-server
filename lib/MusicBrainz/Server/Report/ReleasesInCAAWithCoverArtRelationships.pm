package MusicBrainz::Server::Report::ReleasesInCAAWithCoverArtRelationships;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub component_name { 'ReleasesInCaaWithCoverArtRelationships' }

sub query {
    "
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM (
            SELECT DISTINCT r.*
            FROM release r
            JOIN cover_art_archive.cover_art ON cover_art.release = r.id
            JOIN l_release_url lru ON entity0 = r.id
            JOIN link l ON l.id = lru.link
            JOIN link_type lt ON lt.id = l.link_type
            WHERE lt.gid = '2476be45-3090-43b3-a948-a8f972b4065c'
            AND lru.edits_pending = 0
        ) r
        JOIN artist_credit ac ON r.artist_credit = ac.id
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
