package MusicBrainz::Server::Report::ReleaseReport;
use Moose;

extends 'MusicBrainz::Server::Report';

use List::MoreUtils qw( uniq );

sub post_load
{
    my ($self, $items) = @_;

    my @ids = map { $_->{artist_credit_id} } @$items;
    my $acs = $self->c->model('ArtistCredit')->get_by_ids(@ids);

    my @releasegids = map { $_->{release_gid} } @$items;
    my $releases = $self->c->model('Release')->get_by_gids(@releasegids);

    my @urlgids = map { $_->{url_gid} } @$items;
    my $urls = $self->c->model('URL')->get_by_gids(@urlgids);

    foreach my $item (@$items) {
        $item->{artist_credit} = $acs->{$item->{artist_credit_id}};
        $item->{release} = $releases->{$item->{release_gid}};

        $item->{urlentity} = $urls->{$item->{url_gid}} if $item->{url_gid};
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
