package MusicBrainz::Server::Data::EntityAnnotation;
use Moose;
use namespace::autoclean;

use List::AllUtils qw( uniq );

use MusicBrainz::Server::Constants qw( $EDITOR_MODBOT %ENTITIES );
use MusicBrainz::Server::Entity::Annotation;
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    type_to_model
);

extends 'MusicBrainz::Server::Data::Entity';

has [qw( type table )] => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

sub _table
{
    my $self = shift;
    return $self->table . ' ea
            JOIN annotation a ON ea.annotation=a.id';
}

sub _columns
{
    return 'id, editor AS editor_id, text, changelog,
            created AS creation_date';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Annotation';
}

sub get_history
{
    my ($self, $id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE ' . $self->type . ' = ?' .
                ' ORDER BY created DESC';
    $self->query_to_list_limited($query, [$id], $limit, $offset);
}

sub get_latest
{
    my ($self, $id) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE ' . $self->type . ' = ?' .
                ' ORDER BY created DESC, id DESC LIMIT 1';
    my $row = $self->sql->select_single_row_hash($query, $id)
        or return undef;
    return $self->_new_from_row($row);
}

sub load_latest
{
    my ($self, @objs) = @_;
    for my $obj (@objs) {
        next unless $obj->does('MusicBrainz::Server::Entity::Role::Annotation');
        my $annotation = $self->get_latest($obj->id) or next;
        $obj->latest_annotation($annotation);
    }
}

sub edit
{
    my ($self, $annotation_hash) = @_;
    my $annotation_id = $self->sql->insert_row('annotation', {
        editor => $annotation_hash->{editor_id},
        text => $annotation_hash->{text},
        changelog => $annotation_hash->{changelog}
    }, 'id');
    $self->sql->insert_row($self->table, {
        $self->type => $annotation_hash->{entity_id},
        annotation => $annotation_id
    });
    return $annotation_id;
}

sub delete
{
    my ($self, @ids) = @_;
    my $query = 'DELETE FROM ' . $self->table .
                ' WHERE ' . $self->type . ' IN (' . placeholders(@ids) . ')' .
                ' RETURNING annotation';
    my $annotations = $self->sql->select_single_column_array($query, @ids);
    return 1 unless scalar @$annotations;
    $query = 'DELETE FROM annotation WHERE id IN (' . placeholders(@$annotations) . ')';
    $self->sql->do($query, @$annotations);
    return 1;
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;
    my $table = $self->table;
    my $type = $self->type;
    my $model = type_to_model($type);

    my @ids = ($new_id, @old_ids);
    my %entity_to_annotation = map { @$_ } @{
        $self->sql->select_list_of_lists(
            "SELECT $type, text
             FROM (
                 SELECT $type, text, row_number() OVER (PARTITION BY $type ORDER BY created DESC)
                 FROM annotation
                 JOIN $table ent_annotation ON ent_annotation.annotation = annotation.id
                 WHERE $type IN (".placeholders(@ids).')
             ) s
             WHERE row_number = 1',
            @ids
        )
    };

    my $current_target_annotation_text = $entity_to_annotation{$new_id} // '';

    my $modbot = $self->c->model('Editor')->get_by_id($EDITOR_MODBOT);
    if (keys %entity_to_annotation > 1) {
        my $new_text = join("\n\n-------\n\n",
                            uniq
                            grep { $_ ne '' }
                            map { $entity_to_annotation{$_} // '' }
                            @ids);
        if ($new_text ne '' && $new_text ne $current_target_annotation_text) {
            $self->c->model('Edit')->create(
                edit_type => $ENTITIES{$type}{annotations}{edit_type},
                editor => $modbot,
                entity => $self->c->model($model)->get_by_id($new_id),
                text => $new_text,
                changelog => "Result of $type merge"
            );
        }
    }

    $self->sql->do("UPDATE $table SET $type = ?
              WHERE $type IN (".placeholders(@old_ids).')', $new_id, @old_ids);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Data::Annotation

=head1 DESCRIPTION

Provides support for loading annotations from the database.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

