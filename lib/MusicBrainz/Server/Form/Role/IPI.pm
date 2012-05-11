package MusicBrainz::Server::Form::Role::IPI;
use HTML::FormHandler::Moose::Role;

has_field 'ipi_codes'          => ( type => 'Repeatable', num_when_empty => 1 );
has_field 'ipi_codes.contains' => ( type => '+MusicBrainz::Server::Form::Field::IPI' );

after 'BUILD' => sub {
    my ($self) = @_;

    if (defined $self->init_object) {
        $self->field('ipi_codes')->value([
            map { $_->ipi } $self->init_object->all_ipi_codes
        ]);
    }
};

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
