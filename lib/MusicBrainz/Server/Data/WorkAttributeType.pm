package MusicBrainz::Server::Data::WorkAttributeType;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( load_subobjects hash_to_row );
use MusicBrainz::Server::Entity::WorkAttributeType;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'work_attribute_type' }

sub _table
{
    return 'work_attribute_type';
}

sub _columns
{
    return 'id, name, free_text, parent, child_order, comment, description';
}

sub _column_mapping
{
    return {
        id          => 'id',
        name        => 'name',
        comment     => 'comment',
        free_text   => 'free_text',
        parent_id   => 'parent',
        child_order => 'child_order',
        description => 'description',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::WorkAttributeType';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM work_attribute WHERE work_attribute_type = ? LIMIT 1',
        $id);
}

__PACKAGE__->meta->make_immutable;
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
