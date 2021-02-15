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

sub TO_JSON {
    my ($self) = @_;

    return {
        latitude => $self->latitude,
        longitude => $self->longitude,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
