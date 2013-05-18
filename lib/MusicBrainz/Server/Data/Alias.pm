package MusicBrainz::Server::Data::Alias;
use Moose;
use namespace::autoclean;

use Class::MOP;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    load_subobjects
    placeholders
    query_to_list
);
use MusicBrainz::Server::Entity::PartialDate;

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
    if ($self->type eq 'area') {
        return $self->table;
    } else {
        return sprintf '%s JOIN %s name ON %s.name=name.id JOIN %s sort_name ON %s.sort_name=sort_name.id',
            $self->table, $self->parent->name_table, $self->table, $self->parent->name_table, $self->table;
    }
}

sub _columns
{
    my $self = shift;
    return sprintf '%s.id, %s, %s AS sort_name, %s, locale,
                    edits_pending, begin_date_year, begin_date_month,
                    begin_date_day, end_date_year, end_date_month,
                    end_date_day, type AS type_id, primary_for_locale',
        $self->table, $self->_name, $self->_sort_name, $self->type;
}

sub _name {
    my $self = shift;
    return $self->type eq 'area' ? $self->table . '.name' : 'name.name';
}

sub _sort_name {
    my $self = shift;
    return $self->type eq 'area' ? $self->table . '.sort_name' : 'sort_name.name';
}

sub _column_mapping
{
    my $self = shift;
    return {
        id                  => 'id',
        name                => 'name',
        sort_name           => 'sort_name',
        $self->type . '_id' => $self->type,
        edits_pending       => 'edits_pending',
        locale              => 'locale',
        type_id             => 'type_id',
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        primary_for_locale  => 'primary_for_locale'
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
                 ORDER BY locale NULLS LAST, musicbrainz_collate(" . $self->_sort_name . "), musicbrainz_collate(" . $self->_name . ")";

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
    # Only use name tables if it's not an area
    my %names;
    if ($type ne 'area') {
        %names = $self->parent->find_or_insert_names(map { $_->{name}, $_->{sort_name} } @alias_hashes);
    } else {
        %names = map { $_->{name} => $_->{name}, $_->{sort_name} => $_->{sort_name} } @alias_hashes;
    }
    my @created;
    Class::MOP::load_class($class);
    for my $hash (@alias_hashes) {
        my $row = {
            $type => $hash->{$type . '_id'},
            name =>  $names{ $hash->{name} },
            locale => $hash->{locale},
            sort_name => $names{ $hash->{sort_name} },
            primary_for_locale => $hash->{primary_for_locale},
            type => $hash->{type_id},
        };

        add_partial_date_to_row($row, $hash->{begin_date}, "begin_date");
        add_partial_date_to_row($row, $hash->{end_date}, "end_date");

        push @created, $class->new(id => $self->sql->insert_row($table, $row, 'id'));
    }
    return wantarray ? @created : $created[0];
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;
    my $table = $self->table;
    my $type = $self->type;

    # Fix primary_for_locale:
    # turn off primary_for_locale on all but one per locale, preferring the target entity
    # therefore, partition by locale only
    $self->sql->do(
        "UPDATE $table SET primary_for_locale = FALSE
          WHERE id IN (
             SELECT a.id FROM (
                 SELECT id, rank() OVER (PARTITION BY locale
                                         ORDER BY primary_for_locale DESC, ($type = ?) DESC) > 1 AS redundant
                   FROM $table WHERE $type = any(?)
             ) a WHERE redundant
         )", $new_id, [ $new_id, @old_ids ]
    );

    # Merge based on all properties of each alias, other than primary_for_locale,
    # preferring primary_for_locale and the target entity
    # therefore, partition by everything except primary_by_locale
    $self->sql->do(
        "DELETE FROM $table WHERE id in (
             SELECT a.id FROM (
                 SELECT id, rank() OVER (PARTITION BY $type, name, locale, type, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day
                                         ORDER BY primary_for_locale DESC, ($type = ?) DESC) > 1 AS redundant
                   FROM $table WHERE $type = any(?)
             ) a WHERE redundant
        )", $new_id, [ $new_id, @old_ids ]
    );

    # Update all aliases to the new entity
    $self->sql->do("UPDATE $table SET $type = ?
              WHERE $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);

    # Insert any aliases from old entity names
    my $sortnamecol = $type eq 'work' ? 'name' : 'sort_name';
    $self->sql->do(
        "INSERT INTO $table (name, $type, sort_name)
            SELECT DISTINCT ON (old_entity.name) old_entity.name, new_entity.id, old_entity.$sortnamecol
              FROM $type old_entity
         LEFT JOIN $table alias ON alias.name = old_entity.name
              JOIN $type new_entity ON (new_entity.id = ?)
             WHERE old_entity.id = any(?)
               AND alias.id IS NULL
               AND old_entity.name != new_entity.name",
        $new_id, [ @old_ids ]
    );
}

sub update
{
    my ($self, $alias_id, $alias_hash) = @_;
    my $table = $self->table;
    my $type = $self->type;

    my %row = %$alias_hash;
    delete @row{qw( begin_date end_date )};

    # Only change to name tables if it's not an area
    if ($type ne 'area') {
        delete @row{qw( name )};
        if (exists $alias_hash->{name}) {
            my %names = $self->parent->find_or_insert_names($alias_hash->{name});
            $row{name} = $names{ $alias_hash->{name} };
        }

        if (exists $alias_hash->{sort_name}) {
            my %names = $self->parent->find_or_insert_names($alias_hash->{sort_name});
            $row{sort_name} = $names{ $alias_hash->{sort_name} };
        }
    }

    add_partial_date_to_row(\%row, $alias_hash->{begin_date}, "begin_date")
        if exists $alias_hash->{begin_date};
    add_partial_date_to_row(\%row, $alias_hash->{end_date}, "end_date")
        if exists $alias_hash->{end_date};
    $row{type} = delete $row{type_id}
        if exists $row{type_id};

    $self->sql->update_row($table, \%row, { id => $alias_id });
}

sub exists {
    my ($self, $alias) = @_;
    my $name_table = $self->parent->name_table;
    my $table = $self->table;
    my $type = $self->type;
    return $self->sql->select_single_value(
        "SELECT EXISTS (
             SELECT TRUE
             FROM $table " .
             ($type ne 'area' ? "JOIN $name_table name ON $table.name = name.id " : "") .
             "WHERE " . $self->_name . " IS NOT DISTINCT FROM ?
               AND locale IS NOT DISTINCT FROM ?
               AND type IS NOT DISTINCT FROM ?
               AND $table.id IS DISTINCT FROM ?
               AND $type = ?
         )", $alias->{name}, $alias->{locale}, $alias->{type_id}, $alias->{not_id}, $alias->{entity}
    );
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

