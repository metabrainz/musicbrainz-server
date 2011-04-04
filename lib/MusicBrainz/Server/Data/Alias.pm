package MusicBrainz::Server::Data::Alias;
use Moose;

use Class::MOP;
use MusicBrainz::Server::Data::Utils qw( load_subobjects placeholders query_to_list );

extends 'MusicBrainz::Server::Data::Entity';

# with MusicBrainz::Server::Data::Role::Editable -- see AliasRole for when this is applied

has 'parent' => (
    does => 'MusicBrainz::Server::Data::Role::Name',
    is => 'rw',
    required => 1,
    weak_ref => 1
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
    return sprintf '%s.id, name.name, %s, locale, edits_pending',
        $self->table, $self->type;
}

sub _column_mapping
{
    my $self = shift;
    return {
        id                  => 'id',
        name                => 'name',
        $self->type . '_id' => $self->type,
        edits_pending       => 'edits_pending',
        locale              => 'locale'
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
    return [] unless @ids;

    my $key = $self->type;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE $key IN (" . placeholders(@ids) . ")
                 ORDER BY musicbrainz_collate(name.name)";

    return [ query_to_list($self->c->sql, sub {
        $self->_new_from_row(@_)
    }, $query, @ids) ];
}

sub has_locale
{
    my ($self, $entity_id, $locale_name, $filter) = @_;
    return unless defined $locale_name;
    my $type = $self->type;
    my $query = 'SELECT 1 FROM ' . $self->_table .
        " WHERE $type = ? AND locale = ?";
    my @args = ($entity_id, $locale_name);
    if (defined $filter) {
        $query .= ' AND ' . $type . '_alias.id != ?';
        push @args, $filter;
    }
    return defined $self->sql->select_single_value($query, @args);
}

sub load
{
    my ($self, @objects) = @_;
    load_subobjects($self, 'alias', @objects);
}

sub delete
{
    my ($self, @ids) = @_;
    my $query = "DELETE FROM " . $self->table .
                " WHERE id IN (" . placeholders(@ids) . ")";
    $self->sql->do($query, @ids);
    return 1;
}

sub delete_entities
{
    my ($self, @ids) = @_;
    my $query = "DELETE FROM " . $self->table .
                " WHERE " . $self->type . " IN (" . placeholders(@ids) . ")";
    $self->sql->do($query, @ids);
    return 1;
}

sub insert
{
    my ($self, @alias_hashes) = @_;
    my ($table, $type, $class) = ($self->table, $self->type, $self->entity);
    my %names = $self->parent->find_or_insert_names(map { $_->{name} } @alias_hashes);
    my @created;
    Class::MOP::load_class($class);
    for my $hash (@alias_hashes) {
        push @created, $class->new(
            id => $self->sql->insert_row($table, {
                $type  => $hash->{$type . '_id'},
                name   => $names{ $hash->{name} },
                locale => $hash->{locale}
            }, 'id'));
    }
    return wantarray ? @created : $created[0];
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;
    my $table = $self->table;
    my $type = $self->type;
    $self->sql->do("DELETE FROM $table
              WHERE name IN (SELECT name FROM $table WHERE $type = ?) AND
                    $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);
    $self->sql->do("UPDATE $table SET $type = ?
              WHERE $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);
    $self->sql->do(
        "INSERT INTO $table (name, $type)
            SELECT $type.name, ?::INTEGER
              FROM $type
         LEFT JOIN $table alias ON alias.name = $type.name
             WHERE $type.id IN (" . placeholders(@old_ids) . ")
               AND alias.id IS NULL",
        $new_id, @old_ids
    );
}

sub update
{
    my ($self, $alias_id, $alias_hash) = @_;
    my $table = $self->table;
    my $type = $self->type;
    if (exists $alias_hash->{name}) {
        my %names = $self->parent->find_or_insert_names($alias_hash->{name});
        $alias_hash->{name} = $names{ $alias_hash->{name} };
    }
    $self->sql->update_row($table, $alias_hash, { id => $alias_id });
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

