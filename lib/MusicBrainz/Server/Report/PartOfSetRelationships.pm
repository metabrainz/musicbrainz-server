package MusicBrainz::Server::Report::PartOfSetRelationships;
use Moose;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
        SELECT DISTINCT
            r.gid AS release_gid, rn.name, r.artist_credit AS artist_credit_id,
            musicbrainz_collate(an.name) artist_collate,
            musicbrainz_collate(rn.name) release_collate
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
            JOIN release_name rn ON r.name = rn.id
            JOIN artist_credit ac ON r.artist_credit = ac.id
            JOIN artist_name an ON ac.name = an.id
        WHERE
            link_type.name = 'part of set'
        ORDER BY musicbrainz_collate(an.name), musicbrainz_collate(rn.name)
    ");
}

sub template
{
    return 'report/part_of_set_relationships.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
