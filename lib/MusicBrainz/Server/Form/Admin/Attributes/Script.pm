package MusicBrainz::Server::Form::Admin::Attributes::Script;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( iso_code iso_number name frequency ) }

has '+name' => ( default => 'attr' );

has_field 'name' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'iso_code' => (
    type => 'Text',
    required  => 1,
    maxlength => 4,
);

has_field 'iso_number' => (
    type => 'Text',
    maxlength => 3,
);

has_field 'frequency' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
);

1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
