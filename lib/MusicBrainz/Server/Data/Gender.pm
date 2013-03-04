package MusicBrainz::Server::Data::Gender;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Gender;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'g' };
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _table
{
    return 'gender';
}

sub _columns
{
    return 'id, name';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Gender';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'gender', @objs);
}

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
