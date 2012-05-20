package MusicBrainz::Server::Report::PossibleCollaborations;
use Moose;

extends 'MusicBrainz::Server::Report::ArtistReport';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
        SELECT artist.gid AS artist_gid, name.name
        FROM
            artist
            LEFT JOIN l_artist_artist ON l_artist_artist.entity1=artist.id
            LEFT JOIN link ON link.id=l_artist_artist.link
            LEFT JOIN link_type ON link_type.id=link.link_type
            LEFT JOIN artist_name AS name ON artist.name=name.id
        WHERE
            name.name ~ '&' AND
            (link_type.name IS NULL OR link_type.name NOT IN ('collaboration', 'member of band'))
        GROUP BY artist.gid, name.name
        ORDER BY musicbrainz_collate(name.name);
    ");
}

sub template
{
    return 'report/possible_collaborations.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation

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
