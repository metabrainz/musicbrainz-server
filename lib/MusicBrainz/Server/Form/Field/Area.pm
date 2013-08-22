package MusicBrainz::Server::Form::Field::Area;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Field::Compound';

has_field 'name' => ( type => 'Text' );
has_field 'gid' => ( type => '+MusicBrainz::Server::Form::Field::GID' );

=head1 LICENSE

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

1;

