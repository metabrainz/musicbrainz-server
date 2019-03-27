package MusicBrainz::Server::Entity::Script;

use Moose;
use MusicBrainz::Server::Translation::Scripts qw( l );

extends 'MusicBrainz::Server::Entity';

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

sub l_name {
    my $self = shift;
    return l($self->name);
}

has 'iso_code' => (
    is => 'rw',
    isa => 'Str'
);

has 'iso_number' => (
    is => 'rw',
    isa => 'Str'
);

has 'frequency' => (
    is => 'rw',
    isa => 'Int'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{name} = $self->name;
    $json->{iso_code} = $self->iso_code;
    $json->{iso_number} = $self->iso_number;
    $json->{frequency} = $self->frequency;
    return $json;
};

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
