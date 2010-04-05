package MusicBrainz::Server::Data::Alias;
use Moose;

use Fey::SQL;
use Method::Signatures::Simple;
use MusicBrainz::Server::Data::Utils qw( hash_to_row placeholders );

extends 'MusicBrainz::Server::Data::FeyEntity';

# See AliasRole for when these are applied:
# with MusicBrainz::Server::Data::Role::Editable
# with MusicBrainz::Server::Data::Role::Name
with 'MusicBrainz::Server::Data::Role::Joined';
with 'MusicBrainz::Server::Data::Role::Subobject' => { prefix => 'alias' };

method _column_mapping
{
    return {
        id                  => 'id',
        name                => 'name',
        $self->type . '_id' => $self->type,
        edits_pending       => 'editpending',
        locale              => 'locale'
    };
}

sub _entity_class
{
    return shift->parent->_entity_class . 'Alias';
}

method find_by_entity_id (@ids)
{
    return [ values %{ $self->_get_by_keys($self->_join_column, @ids) } ];
}

method has_alias ($entity_id, $alias_name)
{
    my $name = $self->name_columns->{name};
    my $query = Fey::SQL->new_select
            ->select(1)
            ->from($self->table, $name->table)
            ->where($self->_join_column, '=', $entity_id)
            ->where($name, '=', $alias_name);

    return $self->sql->select_single_value(
        $query->sql($self->sql->dbh), $query->bind_params
    );
}

method delete_entities (@ids)
{
    my $query = Fey::SQL->new_delete
        ->from($self->table)
        ->where($self->_join_column, 'IN', @ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    return 1;
}

method merge ($new_id, @old_ids)
{
    my $query;

    my $sub_q = Fey::SQL->new_select
        ->select($self->table->column('name'))
        ->from($self->table)
        ->where($self->_join_column, '=', $new_id);

    $query = Fey::SQL->new_delete
        ->from($self->table)
        ->where($self->table->column('name'), 'IN', $sub_q)
        ->where($self->_join_column, 'IN', @old_ids);
    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);

    $query = Fey::SQL->new_update
        ->update($self->table)
        ->set($self->_join_column, $new_id)
        ->where($self->_join_column, 'IN', @old_ids);
    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
}

method _hash_to_row ($alias)
{
    return hash_to_row($alias, {
        $self->type => $self->type . '_id',
        locale      => 'locale',
        name        => 'name',
    });
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Data::ArtistAlias - database level loading support for
artist aliases.

=head1 DESCRIPTION

Provides support for loading artist aliases from the database.

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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

