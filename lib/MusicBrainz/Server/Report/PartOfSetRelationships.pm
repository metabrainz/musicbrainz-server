package MusicBrainz::Server::Report::PartOfSetRelationships;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM (
            SELECT DISTINCT r.*
            FROM (
              SELECT
                entity0 AS entity, link
              FROM
                l_release_release
              UNION
              SELECT
                entity1 AS entity, link
              FROM
                l_release_release
            ) AS lrr
            JOIN link ON link.id = lrr.link
            JOIN link_type ON link.link_type = link_type.id
            JOIN release r ON lrr.entity = r.id
            WHERE link_type.name = 'part of set'
        ) r
        JOIN artist_credit ac ON r.artist_credit = ac.id
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
