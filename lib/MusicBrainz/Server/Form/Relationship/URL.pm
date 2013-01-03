package MusicBrainz::Server::Form::Relationship::URL;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Relationship::LinkType';

has '+name' => ( default => 'ar' );

has_field 'url' => (
    type => '+MusicBrainz::Server::Form::Field::URL',
    required => 1,
);

1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
