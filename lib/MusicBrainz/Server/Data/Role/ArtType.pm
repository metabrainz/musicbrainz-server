package MusicBrainz::Server::Data::Role::ArtType;

use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Entity::CoverArtType;
use MusicBrainz::Server::Entity::EventArtType;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    object_to_ids
);

with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::Attribute';

requires qw(
  _type
  _entity_class
  art_schema
  art_type_table
);

sub _table {
    my $schema = shift->art_schema;
    return "$schema.art_type";
}

our @column_names = (
  'id',
  'gid',
  'name',
  'parent AS parent_id',
  'child_order',
  'description',
);

sub _columns {
    my $schema = shift->art_schema;
    return join q(, ), map { "$schema.art_type.$_" } @column_names;
}

sub load {
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
}

sub get_by_name {
    my ($self, @names) = @_;

    my %types_by_name = map { $_->name => $_ } $self->get_all();

    return map { $types_by_name{$_} } @names;
}

sub find_by_art_ids {
    my ($self, @ids) = @_;

    return {} unless @ids;

    my $table = $self->_table;
    my $type_table = $self->art_type_table;
    my $columns = $self->_columns;

    my $query = <<~"SQL";
        SELECT $type_table.id AS art_id, $columns
          FROM $table
          JOIN $type_table ON $type_table.type_id = art_type.id
         WHERE $type_table.id = any(?)
        SQL

    my %map;
    for my $row (@{ $self->sql->select_list_of_hashes($query, \@ids) }) {
        $map{ $row->{art_id} } //= [];
        push @{ $map{ $row->{art_id} } }, $self->_new_from_row($row);
    }

    return \%map;
}

sub load_for {
    my ($self, @objects) = @_;
    my %obj_id_map = object_to_ids(@objects);

    my $id_types_map = $self->find_by_art_ids(keys %obj_id_map);

    while (my ($art_id, $types) = each %$id_types_map) {
        $obj_id_map{$art_id}[0]->types($types);
    }
}

sub in_use {
    my ($self, $id) = @_;

    my $schema = $self->art_schema;
    my $type_table = $self->art_type_table;

    return $self->sql->select_single_value(
        "SELECT 1 FROM $schema.$type_table WHERE type_id = ? LIMIT 1",
        $id,
    );
}

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
