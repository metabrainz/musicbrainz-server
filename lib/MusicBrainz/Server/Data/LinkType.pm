package MusicBrainz::Server::Data::LinkType;

use Moose;
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'link_type';
}

sub _columns
{
    return 'id, parent AS parent_id, gid, name, linkphrase AS link_phrase,
            entitytype0 AS entity0_type, entitytype1 AS entity1_type,
            rlinkphrase AS reverse_link_phrase,
            shortlinkphrase AS short_link_phrase';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::LinkType';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
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
