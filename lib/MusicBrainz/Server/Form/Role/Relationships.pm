package MusicBrainz::Server::Form::Role::Relationships;
use HTML::FormHandler::Moose::Role;

has_field 'url' => (
    type => 'Repeatable',
);

has_field 'url.contains' => (
    type => '+MusicBrainz::Server::Form::Field::Relationship',
);

has_field 'rel' => (
    type => 'Repeatable',
);

has_field 'rel.contains' => (
    type => '+MusicBrainz::Server::Form::Field::Relationship',
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
