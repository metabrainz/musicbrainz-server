package MusicBrainz::Server::Data::IPI;
use Moose;
use namespace::autoclean;

use Class::MOP;
use MusicBrainz::Server::Data::Utils qw( load_subobjects placeholders query_to_list );

extends 'MusicBrainz::Server::Data::Entity';

has [qw( table type entity )] => (
    isa      => 'Str',
    is       => 'rw',
    # required => 1     # FIXME: should be required.
);

sub _table { shift->type . "_ipi" }
sub _columns { shift->type . ", ipi" }

sub _column_mapping
{
    my $self = shift;
    return {
        ipi                  => 'ipi',
        $self->type . '_id' => $self->type,
        edits_pending       => 'edits_pending',
    };
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
                 WHERE $key IN (" . placeholders(@ids) . ")";

    return [ query_to_list($self->c->sql, sub {
        $self->_new_from_row(@_)
    }, $query, @ids) ];
}

sub load
{
    my ($self, @objects) = @_;
    load_subobjects($self, 'ipi', @objects);
}

sub delete
{
    my ($self, @ipis) = @_;
    my $query = "DELETE FROM " . $self->table .
                " WHERE ipi IN (" . placeholders(@ipis) . ")";
    $self->sql->do($query, @ipis);
    return 1;
}

# sub insert
# {
#     my ($self, @alias_hashes) = @_;
#     my ($table, $type, $class) = ($self->table, $self->type, $self->entity);
#     my %names = $self->parent->find_or_insert_names(map { $_->{name} } @alias_hashes);
#     my @created;
#     Class::MOP::load_class($class);
#     for my $hash (@alias_hashes) {
#         push @created, $class->new(
#             id => $self->sql->insert_row($table, {
#                 $type  => $hash->{$type . '_id'},
#                 name   => $names{ $hash->{name} },
#                 locale => $hash->{locale}
#             }, 'id'));
#     }
#     return wantarray ? @created : $created[0];
# }

# sub merge
# {
#     my ($self, $new_id, @old_ids) = @_;
#     my $table = $self->table;
#     my $type = $self->type;
#     $self->sql->do("DELETE FROM $table
#               WHERE name IN (SELECT name FROM $table WHERE $type = ?) AND
#                     $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);
#     $self->sql->do("UPDATE $table SET $type = ?
#               WHERE $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);
#     $self->sql->do(
#         "INSERT INTO $table (name, $type)
#             SELECT DISTINCT ON (old_entity.name) old_entity.name, new_entity.id
#               FROM $type old_entity
#          LEFT JOIN $table alias ON alias.name = old_entity.name
#               JOIN $type new_entity ON (new_entity.id = ?)
#              WHERE old_entity.id IN (" . placeholders(@old_ids) . ")
#                AND alias.id IS NULL
#                AND old_entity.name != new_entity.name",
#         $new_id, @old_ids
#     );
# }

# sub update
# {
#     my ($self, $alias_id, $alias_hash) = @_;
#     my $table = $self->table;
#     my $type = $self->type;
#     if (exists $alias_hash->{name}) {
#         my %names = $self->parent->find_or_insert_names($alias_hash->{name});
#         $alias_hash->{name} = $names{ $alias_hash->{name} };
#     }
#     $self->sql->update_row($table, $alias_hash, { id => $alias_id });
# }

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
