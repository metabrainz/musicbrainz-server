package MusicBrainz::Server::Data::Tag;

use Moose;
use MusicBrainz::Server::Entity::Tag;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::EntityCache' => { prefix => 'tag' };

sub _table
{
    return 'tag';
}

sub _columns
{
    return 'id, name';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Tag';
}

sub get_by_name
{
    my ($self, $name) = @_;
    my @result = values %{$self->_get_by_keys('name', $name)};
    return $result[0];
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'tag', @objs);
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
