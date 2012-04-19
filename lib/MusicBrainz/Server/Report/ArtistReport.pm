package MusicBrainz::Server::Report::ArtistReport;
use Moose;

extends 'MusicBrainz::Server::Report';

sub post_load
{
    my ($self, $items) = @_;

    my @ids = grep { $_ } map { $_->{type} } @$items;
    my $types = $self->c->model('ArtistType')->get_by_ids(@ids);

    my @artistids = map { $_->{artist_gid} } @$items;
    my $artists = $self->c->model('Artist')->get_by_gids(@artistids);

    foreach my $item (@$items) {
        if (defined $item->{type}) {
            $item->{type_id} = $item->{type};
            $item->{type} = $types->{$item->{type_id}};
        }
        $item->{artist} = $artists->{$item->{artist_gid}};
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
