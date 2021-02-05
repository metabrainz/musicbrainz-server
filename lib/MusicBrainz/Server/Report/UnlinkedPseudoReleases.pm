package MusicBrainz::Server::Report::UnlinkedPseudoReleases;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
SELECT r.id AS release_id,
  row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
FROM release r
        JOIN release_status rs ON r.status = rs.id
        LEFT JOIN l_release_release lrr ON r.id = lrr.entity1
        LEFT JOIN link l ON lrr.link = l.id AND l.link_type IN (
                SELECT lt.id
                FROM link_type lt
                WHERE lt.name='transl-tracklisting'
        )
        JOIN artist_credit ac ON r.artist_credit = ac.id
WHERE r.status IN (
        SELECT rs.id
        FROM release_status rs
        WHERE rs.name = 'Pseudo-Release'
) AND lrr.link IS NULL
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2012 Calvin Walton
Based on code (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
