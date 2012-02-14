package MusicBrainz::Server::Report::UnlinkedPseudoReleases;
use Moose;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
SELECT r.gid, rn.name, r.artist_credit AS artist_credit_id
FROM release r
        JOIN release_name rn ON r.name = rn.id
        JOIN release_status rs ON r.status = rs.id
        LEFT JOIN l_release_release lrr ON r.id = lrr.entity1
        LEFT JOIN link l ON lrr.link = l.id AND l.link_type IN (
                SELECT lt.id
                FROM link_type lt
                WHERE lt.name='transl-tracklisting'
        )
        JOIN artist_credit ac ON r.artist_credit = ac.id
        JOIN artist_name an ON ac.name = an.id
WHERE r.status IN (
        SELECT rs.id
        FROM release_status rs
        WHERE rs.name = 'Pseudo-Release'
) AND lrr.link IS NULL
ORDER BY musicbrainz_collate(an.name), musicbrainz_collate(rn.name);
    ");
}

sub template
{
    return 'report/unlinked_pseudo_releases.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Calvin Walton
Based on code (C) 2009 Lukas Lalinsky

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
