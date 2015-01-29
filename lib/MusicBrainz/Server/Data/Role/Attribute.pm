package MusicBrainz::Server::Data::Role::Attribute;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _columns {
    return 'id, name, parent, child_order, description';
}

sub _column_mapping {
    return {
        id              => 'id',
        name            => 'name',
        parent_id       => 'parent',
        child_order     => 'child_order',
        description     => 'description',
    };
}

no Moose;
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
