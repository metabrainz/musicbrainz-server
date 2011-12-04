package MusicBrainz::Server::Report::RecordingReport;
use Moose;

extends 'MusicBrainz::Server::Report';

use List::MoreUtils qw( uniq );

sub post_load
{
    my ($self, $items) = @_;

    my @ids = map { $_->{artist_credit_id} } @$items;
    my $acs = $self->c->model('ArtistCredit')->get_by_ids(@ids);
    foreach my $item (@$items) {
        $item->{artist_credit} = $acs->{$item->{artist_credit_id}};
    }
}

sub filter_by_artists
{
    my ($self, $items, $artists) = @_;
    @$items =
        grep {
            my $item = $_;
            grep {
                my $ac = $_;
                grep { $_ eq $ac->artist->id } @$artists
            } $item->{artist_credit}->all_names
        } @$items;
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
