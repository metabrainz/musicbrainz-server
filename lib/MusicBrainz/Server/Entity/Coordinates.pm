package MusicBrainz::Server::Entity::Coordinates;

use Moose;
use utf8;

has 'latitude' => (
    is => 'rw',
    isa => 'Num'
);

has 'longitude' => (
    is => 'rw',
    isa => 'Num'
);

sub new_from_row {
    my ($class, $row, $prefix) = @_;
    $prefix //= '';

    return undef unless defined $row->{$prefix . '_x'} && defined $row->{$prefix . '_y'};
    return $class->new( latitude => $row->{$prefix . '_x'},
                        longitude => $row->{$prefix . '_y'} );
}

sub format
{
    my ($self) = @_;

    my @res = (abs($self->latitude) . '°' . ($self->latitude > 0 ? 'N' : 'S'),
               abs($self->longitude) . '°' . ($self->longitude > 0 ? 'E' : 'W'));

    return join(', ', @res);
}

sub osm_url
{
    my ($self, $zoom) = @_;
    return 'http://www.openstreetmap.org/?mlat=' . $self->latitude . '&mlon=' . $self->longitude . '#map=' . join('/', $zoom, $self->latitude, $self->longitude);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
