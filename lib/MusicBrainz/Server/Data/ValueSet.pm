package MusicBrainz::Server::Data::ValueSet;

use List::AllUtils qw( uniq );
use Moose;
use MusicBrainz::Server::Data::Utils qw( object_to_ids );
use namespace::autoclean;
use Time::HiRes qw( time );

extends 'MusicBrainz::Server::Data::Entity';

my @str_params = qw(
    entity_type
    plural_value_type
    value_attribute
    value_class
    value_type
);

has \@str_params => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

sub _entity_attribute { shift->entity_type . q(_id) }

sub _table {
    my $self = shift;

    return $self->entity_type . q(_) . $self->value_type;
}

sub _columns {
    my $self = shift;

    return $self->entity_type . q(, ) . $self->value_type;
}

sub _column_mapping {
    my $self = shift;

    my $entity_attribute    = $self->_entity_attribute;
    my $value_attribute     = $self->value_attribute;

    return {
        $entity_attribute   => $self->entity_type,
        $value_attribute    => $self->value_type,
        edits_pending       => 'edits_pending',
    };
}

sub _entity_class { 'MusicBrainz::Server::Entity::' . shift->value_class }

sub find_by_entity_id {
    my ($self, @ids) = @_;

    return [] unless @ids;

    my $columns     = $self->_columns;
    my $table       = $self->_table;
    my $entity_type = $self->entity_type;
    my $value_type  = $self->value_type;

    my $query = qq{
        SELECT $columns
          FROM $table
         WHERE $entity_type = any(?)
         ORDER BY created, $value_type
    };
    return [$self->query_to_list($query, [\@ids])];
}

sub load_for {
    my ($self, @entities) = @_;

    my $entity_attribute    = $self->_entity_attribute;
    my $value_type          = $self->value_type;
    my $add_method          = qq(add_$value_type);

    my %obj_id_map  = object_to_ids(@entities);
    my $values      = $self->find_by_entity_id(keys %obj_id_map);

    for my $value (@$values) {
        if (my $entities = $obj_id_map{ $value->$entity_attribute }) {
            for my $entity (@$entities) {
                $entity->$add_method($value);
            }
        }
    }

    return;
}

sub delete_entities {
    my ($self, @entity_ids) = @_;

    my $table       = $self->_table;
    my $entity_type = $self->entity_type;

    my $query = qq{DELETE FROM $table WHERE $entity_type = any(?)};
    $self->sql->do($query, \@entity_ids);
    return;
}

sub merge {
    my ($self, $new_id, @old_ids) = @_;

    my @all_ids = ($new_id, @old_ids);

    my $table       = $self->_table;
    my $entity_type = $self->entity_type;
    my $value_type  = $self->value_type;

    # De-duplicate values for the entities, retaining a single value over
    # the set of all entities to be merged.
    $self->sql->do(
        qq{DELETE FROM $table
            WHERE $entity_type = any(?)
              AND ($value_type, $entity_type) NOT IN
                  (SELECT DISTINCT ON ($value_type)
                          $value_type, $entity_type
                     FROM $table
                    WHERE $entity_type = any(?))},
        \@all_ids,
        \@all_ids,
    );

    # Move all values to belong to the entity under $new_id.
    $self->sql->do(
        qq{UPDATE $table
              SET $entity_type = ?
            WHERE $entity_type = any(?)},
        $new_id,
        \@all_ids,
    );

    return;
}

sub set {
    my ($self, $entity_id, @values) = @_;

    my $table       = $self->_table;
    my $entity_type = $self->entity_type;
    my $value_type  = $self->value_type;

    $self->sql->do(
        qq{DELETE FROM $table WHERE $entity_type = ?},
        $entity_id,
    );

    return unless @values;
    @values = uniq @values;

    $self->sql->do(
        qq{INSERT INTO $table ($entity_type, $value_type, created) VALUES } .
            join(q(, ), ('(?, ?, ?)') x @values),
        map { ($entity_id, $_,
               # Preserve the order of @values by giving each row a larger
               # `created` timestamp. This shouldn't matter for IPIs or
               # ISNIs, but may for work languages.
               DateTime::Format::Pg->format_datetime(
                   DateTime->from_epoch(epoch => time))) } @values,
    );
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
