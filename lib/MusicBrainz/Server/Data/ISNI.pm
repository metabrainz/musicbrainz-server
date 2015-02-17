package MusicBrainz::Server::Data::ISNI;
use Moose;
use namespace::autoclean;

use Class::MOP;
use List::AllUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    placeholders
    query_to_list
    object_to_ids
);

extends 'MusicBrainz::Server::Data::Entity';

has [qw( table type entity )] => (
    isa      => 'Str',
    is       => 'rw',
    # required => 1     # FIXME: should be required.
);

sub _table { shift->type . "_isni" }
sub _columns { shift->type . ", isni" }

sub _column_mapping
{
    my $self = shift;
    return {
        isni                  => 'isni',
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
                 WHERE $key IN (" . placeholders(@ids) . ")
                 ORDER BY isni";

    return [ query_to_list($self->c->sql, sub {
        $self->_new_from_row(@_)
    }, $query, @ids) ];
}

sub load_for
{
    my ($self, @objects) = @_;
    my %obj_id_map = object_to_ids(@objects);
    my $isnis = $self->find_by_entity_id(keys %obj_id_map);
    my $id_column = $self->type . '_id';

    for my $isni (@$isnis) {
        if (my $entities = $obj_id_map{ $isni->$id_column }) {
            for my $entity (@$entities) {
                $entity->add_isni_code($isni);
            }
        }
    }

    return $isnis;
}

sub delete_entities
{
    my ($self, @entities) = @_;

    my $query = "DELETE FROM " . $self->table .
                " WHERE ".$self->type." IN (" . placeholders(@entities) . ")";
    $self->sql->do($query, @entities);
    return 1;
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;
    my $table = $self->table;
    my $type = $self->type;

    my @all_ids = ($new_id, @old_ids);

    # De-duplicate ISNIs for entities, retaining a single ISNI over the set of
    # all entities to be merged.
    $self->sql->do("DELETE FROM $table
                    WHERE $type = any(?)
                    AND (isni, $type) NOT IN (
                      SELECT DISTINCT ON (isni) isni, $type
                      FROM $table
                      WHERE $type = any(?))",
                   \@all_ids, \@all_ids);

    # Move all ISNIs to belong to the entity under $new_id
    $self->sql->do("UPDATE $table SET $type = ? WHERE $type = any(?)", $new_id, \@all_ids);
}

sub set_isnis {
    my ($self, $entity_id, @isnis) = @_;
    @isnis = uniq @isnis;
    my $table = $self->table;
    my $type = $self->type;

    $self->sql->do("DELETE FROM $table WHERE $type = ?", $entity_id);
    $self->sql->do(
        "INSERT INTO $table ($type, isni) VALUES " .
            join(', ', ("(?, ?)") x @isnis),
        map { $entity_id, $_ } @isnis
    ) if @isnis;
}

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
