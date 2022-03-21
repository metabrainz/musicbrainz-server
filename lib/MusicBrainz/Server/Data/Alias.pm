package MusicBrainz::Server::Data::Alias;
use Moose;
use namespace::autoclean;

use Class::Load qw( load_class );
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    load_subobjects
    placeholders
);
use MusicBrainz::Server::Entity::PartialDate;

extends 'MusicBrainz::Server::Data::Entity';

# with MusicBrainz::Server::Data::Role::Editable -- see AliasRole for when this is applied

has 'parent' => (
    does => 'MusicBrainz::Server::Data::Role::Alias',
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
    return $self->table;
}

sub _columns
{
    my $self = shift;
    return sprintf '%s.id, name, sort_name, %s, locale,
                    edits_pending, begin_date_year, begin_date_month,
                    begin_date_day, end_date_year, end_date_month,
                    end_date_day, type AS type_id, primary_for_locale, ended',
        $self->table, $self->type;
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
        primary_for_locale  => 'primary_for_locale',
        ended                => 'ended'
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

sub find_by_entity_ids
{
    my ($self, @ids) = @_;
    return {} unless @ids;

    my $key = $self->type;

    my $query = "SELECT $key parent_id, " . $self->_columns . '
                 FROM ' . $self->_table . "
                 WHERE $key IN (" . placeholders(@ids) . ')
                 ORDER BY locale NULLS LAST,
                   primary_for_locale DESC, -- psql does false = 0, true = 1
                   begin_date_year NULLS LAST,
                   begin_date_month NULLS LAST,
                   begin_date_day NULLS LAST,
                   end_date_year NULLS LAST,
                   end_date_month NULLS LAST,
                   end_date_day NULLS LAST,
                   sort_name COLLATE musicbrainz,
                   name COLLATE musicbrainz';

    my %ret = map { $_ => [] } @ids;

    my $rows = $self->sql->select_list_of_hashes($query, @ids);
    while (my $row = shift(@$rows)) {
        push @{ $ret{$row->{parent_id}} },
            $self->_new_from_row($row);
    }

    return \%ret;
}

sub find_by_entity_id
{
    my ($self, @ids) = @_;
    my $alias_map = $self->find_by_entity_ids(@ids);
    return [ map { @{ $alias_map->{$_} } } @ids ];
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
    my $query = 'DELETE FROM ' . $self->table .
                ' WHERE id IN (' . placeholders(@ids) . ')';
    $self->sql->do($query, @ids);
    return 1;
}

sub delete_entities
{
    my ($self, @ids) = @_;
    my $query = 'DELETE FROM ' . $self->table .
                ' WHERE ' . $self->type . ' IN (' . placeholders(@ids) . ')';
    $self->sql->do($query, @ids);
    return 1;
}

sub clear_primary_for_locale {
    my ($self, $locale, $entity_id) = @_;
    my $table = $self->table;
    my $type = $self->type;

    $self->sql->do(<<~"SQL", $locale, $entity_id);
        UPDATE $table
           SET primary_for_locale = FALSE
         WHERE locale = ?
           AND $type = ?
        SQL
}

sub insert
{
    my ($self, @alias_hashes) = @_;
    my ($table, $type, $class) = ($self->table, $self->type, $self->entity);
    my @created;
    load_class($class);
    for my $hash (@alias_hashes) {
        my $entity_id = $hash->{$type . '_id'};
        my $locale = $hash->{locale};
        my $primary_for_locale = $hash->{primary_for_locale};
        my $row = {
            $type => $entity_id,
            name => $hash->{name},
            locale => $locale,
            sort_name => $hash->{sort_name},
            primary_for_locale => $primary_for_locale,
            type => $hash->{type_id},
            ended => $hash->{ended},
        };

        # Clear existing primary for locale flag for the chosen locale
        # if we are overriding them (the user chose this as primary)
        if ($primary_for_locale) {
            $self->clear_primary_for_locale($locale, $entity_id);
        }

        add_partial_date_to_row($row, $hash->{begin_date}, 'begin_date');
        add_partial_date_to_row($row, $hash->{end_date}, 'end_date');

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
                                         ORDER BY primary_for_locale DESC, ($type = ?) DESC, id DESC) > 1 AS redundant
                   FROM $table WHERE $type = any(?)
             ) a WHERE redundant
         )", $new_id, [ $new_id, @old_ids ]
    );

    # Merge based on all properties of each alias, other than primary_for_locale,
    # preferring primary_for_locale and the target entity
    # therefore, partition by everything except primary_by_locale
    $self->sql->do(
        "DELETE FROM $table WHERE id IN (
             SELECT a.id FROM (
                 SELECT id, rank() OVER (PARTITION BY $type, name, locale, type, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day
                                         ORDER BY primary_for_locale DESC, ($type = ?) DESC) > 1 AS redundant
                   FROM $table WHERE $type = any(?)
             ) a WHERE redundant
        )", $new_id, [ $new_id, @old_ids ]
    );

    # Update all aliases to the new entity
    $self->sql->do("UPDATE $table SET $type = ?
              WHERE $type IN (".placeholders(@old_ids).')', $new_id, @old_ids);

    # Insert any aliases from old entity names
    my $sortnamecol = ($type eq 'artist') ? 'sort_name' : 'name';
    $self->sql->do(
        "INSERT INTO $table (name, $type, sort_name)
            SELECT DISTINCT ON (old_entity.name) old_entity.name, new_entity.id, old_entity.$sortnamecol
              FROM $type old_entity
              JOIN $type new_entity ON (new_entity.id = ?)
             WHERE old_entity.id = any(?)
               AND old_entity.name != new_entity.name
               AND NOT EXISTS (
                   SELECT TRUE FROM $table
                    WHERE $type = new_entity.id
                      AND name = old_entity.name
                    LIMIT 1
               )",
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

    # Clear existing primary for locale flag for the chosen locale
    # if we are overriding them (the user chose this as primary)
    if ($row{primary_for_locale}) {
        # We need to load the alias because %row only contains changed values
        my $alias = $self->get_by_id($alias_id);
        my $locale = $row{locale} // $alias->{locale};
        my $entity_id = $alias->{$type . '_id'};
        $self->clear_primary_for_locale($locale, $entity_id);
    }

    add_partial_date_to_row(\%row, $alias_hash->{begin_date}, 'begin_date')
        if exists $alias_hash->{begin_date};
    add_partial_date_to_row(\%row, $alias_hash->{end_date}, 'end_date')
        if exists $alias_hash->{end_date};
    $row{type} = delete $row{type_id}
        if exists $row{type_id};

    $self->sql->update_row($table, \%row, { id => $alias_id });
}

sub exists {
    my ($self, $alias) = @_;
    my $table = $self->table;
    my $type = $self->type;
    return $self->sql->select_single_value(
        "SELECT EXISTS (
             SELECT TRUE
             FROM $table
             WHERE name IS NOT DISTINCT FROM ?
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

