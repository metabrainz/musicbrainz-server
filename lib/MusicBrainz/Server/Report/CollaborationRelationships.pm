package MusicBrainz::Server::Report::CollaborationRelationships;
use Moose;

extends 'MusicBrainz::Server::Report::ArtistReport';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
        SELECT
            artist0.gid AS gid0, name0.name AS name0, artist1.gid AS gid1, name1.name AS name1
        FROM
            l_artist_artist
            JOIN link ON link.id=l_artist_artist.link
            JOIN link_type ON link_type.id=link.link_type
            JOIN artist AS artist0 ON l_artist_artist.entity0=artist0.id
            JOIN artist AS artist1 ON l_artist_artist.entity1=artist1.id
            JOIN artist_name AS name0 ON artist0.name=name0.id
            JOIN artist_name AS name1 ON artist1.name=name1.id
            LEFT JOIN l_artist_url ON l_artist_artist.entity1=l_artist_url.entity0
        WHERE
            link_type.name = 'collaboration' AND
            l_artist_url.id IS NULL
        ORDER BY musicbrainz_collate(name1.name), artist1.id, musicbrainz_collate(name0.name), artist0.id
    ");
}

sub post_load
{
    my ($self, $items) = @_;

    my @gid0s = map { $_->{gid0} } @$items;
    my @gid1s = map { $_->{gid1} } @$items;
    my $artists = $self->c->model('Artist')->get_by_gids(@gid0s, @gid1s);

    foreach my $item (@$items) {
        $item->{artist0} = $artists->{$item->{gid0}};
        $item->{artist1} = $artists->{$item->{gid1}};
    }
}

sub template
{
    return 'report/collaboration_relationships.tt';
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
