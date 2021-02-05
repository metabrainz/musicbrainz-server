package MusicBrainz::Server::Report::SetInDifferentRG;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseGroupID';

sub component_name { 'SetInDifferentRg' }

sub query {
    "
        SELECT DISTINCT
            rg.id AS release_group_id,
            row_number() OVER (ORDER BY rg.name COLLATE musicbrainz)
        FROM release_group rg
            JOIN release rel ON rel.release_group = rg.id
        WHERE rel.id IN (
            SELECT r0.id
            FROM l_release_release l
                JOIN release r0 ON l.entity0 = r0.id
                JOIN release r1 ON l.entity1 = r1.id
                JOIN link ON l.link = link.id
                JOIN link_type ON link.link_type = link_type.id
            WHERE link_type.gid in ('6d08ec1e-a292-4dac-90f3-c398a39defd5', 'fc399d47-23a7-4c28-bfcf-0607a562b644')
                AND r0.release_group <> r1.release_group
            UNION
            SELECT r1.id
            FROM l_release_release l
                JOIN release r0 ON l.entity0 = r0.id
                JOIN release r1 ON l.entity1 = r1.id
                JOIN link ON l.link = link.id
                JOIN link_type ON link.link_type = link_type.id
            WHERE link_type.gid in ('6d08ec1e-a292-4dac-90f3-c398a39defd5', 'fc399d47-23a7-4c28-bfcf-0607a562b644')
                AND r0.release_group <> r1.release_group
        )
    ";
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
