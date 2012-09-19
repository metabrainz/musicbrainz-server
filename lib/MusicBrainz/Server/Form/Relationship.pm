package MusicBrainz::Server::Form::Relationship;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Relationship::LinkType';

has '+name' => ( default => 'ar' );

has_field 'direction'    => ( type => 'Checkbox' );

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
);

has_field 'entity0'      => ( type => 'Compound' );
has_field 'entity0.id'   => ( type => 'Text' );
has_field 'entity0.name' => ( type => 'Text' );

has_field 'entity1'      => ( type => 'Compound' );
has_field 'entity1.id'   => ( type => 'Text' );
has_field 'entity1.name' => ( type => 'Text' );

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
