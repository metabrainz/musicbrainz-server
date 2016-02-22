package MusicBrainz::Server::Data::CollectionType;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::CollectionType;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );
use MusicBrainz::Server::Constants qw( %ENTITIES );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'collection_type' }

sub _table {
    return 'editor_collection_type';
}

sub _columns {
    return 'id, name, entity_type, parent, child_order, description';
}

sub _column_mapping {
    return {
        id              => 'id',
        name            => 'name',
        entity_type     => 'entity_type',
        parent_id       => 'parent',
        child_order     => 'child_order',
        description     => 'description',
    };
}

sub _entity_class {
    return 'MusicBrainz::Server::Entity::CollectionType';
}

sub load {
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM editor_collection WHERE type = ? LIMIT 1',
        $id);
}

sub find_by_entity_type {
    my ($self, $entity_type) = @_;

    $self->query_to_list(
        'SELECT * FROM editor_collection_type WHERE entity_type = ?',
        [$entity_type],
    );
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
