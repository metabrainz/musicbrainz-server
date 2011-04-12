package MusicBrainz::Server::Entity::Country;

use Moose;

extends 'MusicBrainz::Server::Entity';

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

has 'iso_code' => (
    is => 'rw',
    isa => 'Str'
);

=method iso_code_for_display

Any iso code starting with 'X' should be considered internal to how
MusicBrainz operates and never be displayed to the user.  This
function will output normal iso codes for any valid iso code, but
output the name for the X* codes -- possibly shortened if the name
contains a comment about historical usage.

=cut

sub iso_code_for_display {
    my $self = shift;

    return $self->iso_code unless $self->iso_code =~ m/^X/;

    my $name = $self->name;
    $name =~ s/ \(historical.*//;

    return $name;
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
