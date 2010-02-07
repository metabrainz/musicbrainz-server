package MusicBrainz::Server::Data::Alias;
use Moose;

use Class::MOP;
use MusicBrainz::Server::Data::Utils qw( load_subobjects placeholders );

extends 'MusicBrainz::Server::Data::Entity';

# with MusicBrainz::Server::Data::Role::Editable -- see AliasRole for when this is applied

has 'parent' => (
    does => 'MusicBrainz::Server::Data::Role::Name',
    is => 'rw',
    required => 1
);

has [qw( table type entity )] => (
    isa      => 'Str',
    is       => 'rw',
    required => 1
);

sub _table
{
    my $self = shift;
    return sprintf '%s JOIN %s name ON %s.name=name.id',
        $self->table, $self->parent->name_table, $self->table
}

sub _columns
{
    my $self = shift;
    return sprintf '%s.id, name.name, %s, editpending',
        $self->table, $self->type;
}

sub _column_mapping
{
    my $self = shift;
    return {
        id                  => 'id',
        name                => 'name',
        $self->type . '_id' => $self->type,
        edits_pending       => 'editpending',
    };
}

sub _id_column
{
    return shift->table . '.id';
}

sub _entity_class
{
    return shift->entity;
}

sub find_by_entity_id
{
    my ($self, @ids) = @_;
    return [ values %{ $self->_get_by_keys($self->type, @ids) } ];
}

sub has_alias
{
    my ($self, $entity_id, $alias_name) = @_;
    my $sql  = Sql->new($self->c->dbh);
    my $type = $self->type;
    return defined $sql->select_single_value(
        'SELECT 1 FROM ' . $self->_table .
        " WHERE $type = ? AND name.name = ?",
        $entity_id, $alias_name
    );
}

sub load
{
    my ($self, @objects) = @_;
    load_subobjects($self, 'alias', @objects);
}

sub delete
{
    my ($self, @ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $query = "DELETE FROM " . $self->table .
                " WHERE id IN (" . placeholders(@ids) . ")";
    $sql->do($query, @ids);
    return 1;
}

sub delete_entities
{
    my ($self, @ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $query = "DELETE FROM " . $self->table .
                " WHERE " . $self->type . " IN (" . placeholders(@ids) . ")";
    $sql->do($query, @ids);
    return 1;
}

sub insert
{
    my ($self, @alias_hashes) = @_;
    my $sql = Sql->new($self->c->dbh);
    my ($table, $type, $class) = ($self->table, $self->type, $self->entity);
    my %names = $self->parent->find_or_insert_names(map { $_->{name} } @alias_hashes);
    my @created;
    Class::MOP::load_class($class);
    for my $hash (@alias_hashes) {
        push @created, $class->new(
            id => $sql->insert_row($table, {
                $type => $hash->{$type . '_id'},
                name => $names{ $hash->{name} }
            }, 'id'));
    }
    return wantarray ? @created : $created[0];
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $table = $self->table;
    my $type = $self->type;
    $sql->do("DELETE FROM $table
              WHERE name IN (SELECT name FROM $table WHERE $type = ?) AND
                    $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);
    $sql->do("UPDATE $table SET $type = ?
              WHERE $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);
}

sub update
{
    my ($self, $alias_id, $alias_hash) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $table = $self->table;
    my $type = $self->type;
    $sql->update_row($table, $alias_hash, { id => $alias_id });
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

