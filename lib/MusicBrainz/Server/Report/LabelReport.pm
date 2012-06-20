package MusicBrainz::Server::Report::LabelReport;
use Moose;

extends 'MusicBrainz::Server::Report';

sub post_load
{
    my ($self, $items) = @_;

    my @ids = grep { $_ } map { $_->{type} } @$items;
    my $types = $self->c->model('LabelType')->get_by_ids(@ids);

    my @labelids = map { $_->{label_gid} } @$items;
    my $labels = $self->c->model('Label')->get_by_gids(@labelids);

    my @urlgids = map { $_->{url_gid} } @$items;
    my $urls = $self->c->model('URL')->get_by_gids(@urlgids);

    foreach my $item (@$items) {
        if (defined $item->{type}) {
            $item->{type_id} = $item->{type};
            $item->{type} = $types->{$item->{type_id}};
        }
        $item->{label} = $labels->{$item->{label_gid}};
        $item->{urlentity} = $urls->{$item->{url_gid}} if $item->{url_gid};
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Johannes Weißl
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
