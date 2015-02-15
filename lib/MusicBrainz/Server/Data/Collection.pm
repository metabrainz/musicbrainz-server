package MusicBrainz::Server::Data::Collection;

use Moose;
use namespace::autoclean;

use Carp;
use Sql;
use MusicBrainz::Server::Entity::Collection;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    placeholders
    query_to_list
    query_to_list_limited
);
use List::MoreUtils qw( zip );
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_collection',
    column => 'collection',
    active_class => 'MusicBrainz::Server::Entity::CollectionSubscription'
};

sub _type { 'collection' }

sub _columns {
    return 'editor_collection.id, editor_collection.gid, editor_collection.editor, editor_collection.name, public, editor_collection.description, editor_collection.type';
}

sub _id_column {
    return 'id';
}

sub _column_mapping {
    return {
        id => 'id',
        gid => 'gid',
        editor_id => 'editor',
        name => 'name',
        public => 'public',
        description => 'description',
        type_id => 'type',
    };
}

sub find_by_subscribed_editor {
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_collection s ON editor_collection.id = s.collection
                 WHERE s.editor = ? AND s.available
                 ORDER BY musicbrainz_collate(name), editor_collection.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub add_entities_to_collection {
    my ($self, $type, $collection_id, @ids) = @_;
    return unless @ids;

    $self->sql->auto_commit;

    my @collection_ids = ($collection_id) x @ids;
    $self->sql->do("
        INSERT INTO editor_collection_$type (collection, $type)
           SELECT DISTINCT add.collection, add.$type
             FROM (VALUES " . join(', ', ("(?::integer, ?::integer)") x @ids) . ") add (collection, $type)
            WHERE NOT EXISTS (
              SELECT TRUE FROM editor_collection_$type
              WHERE collection = add.collection AND $type = add.$type
              LIMIT 1
            )", zip @collection_ids, @ids);
}

sub remove_entities_from_collection {
    my ($self, $type, $collection_id, @ids) = @_;
    return unless @ids;

    $self->sql->auto_commit;
    $self->sql->do("DELETE FROM editor_collection_$type
              WHERE collection = ? AND $type IN (" . placeholders(@ids) . ")",
              $collection_id, @ids);
}

sub contains_entity {
    my ($self, $type, $collection_id, $id) = @_;

    return $self->sql->select_single_value("
        SELECT 1 FROM editor_collection_$type
        WHERE collection = ? AND $type = ?",
        $collection_id, $id) ? 1 : 0;
}

sub merge_entities {
    my ($self, $type, $new_id, @old_ids) = @_;

    my @ids = ($new_id, @old_ids);

    # Remove duplicate joins (ie, rows with entity from @old_ids and pointing to
    # a collection that already contains $new_id)
    $self->sql->do(
        "DELETE FROM editor_collection_$type
               WHERE $type IN (" . placeholders(@ids) . ")
                 AND (collection, $type) NOT IN (
                     SELECT DISTINCT ON (collection) collection, $type
                       FROM editor_collection_$type
                      WHERE $type IN (" . placeholders(@ids) . ")
                 )",
        @ids, @ids);

    # Move all remaining joins to the new release
    $self->sql->do("UPDATE editor_collection_$type SET $type = ?
              WHERE $type IN (".placeholders(@ids).")",
              $new_id, @ids);
}

sub delete_entities {
    my ($self, $type, @ids) = @_;

    $self->sql->do("DELETE FROM editor_collection_$type
              WHERE $type IN (".placeholders(@ids).")", @ids);
}

sub add_releases_to_collection
{
    my ($self, $collection_id, @ids) = @_;
    $self->add_entities_to_collection("release", $collection_id, @ids);
}

sub remove_releases_from_collection
{
    my ($self, $collection_id, @ids) = @_;
    $self->remove_entities_from_collection("release", $collection_id, @ids);
}

sub check_release
{
    my ($self, $collection_id, $id) = @_;
    return $self->contains_entity("release", $collection_id, $id);
}

sub merge_releases
{
    my ($self, $new_id, @old_ids) = @_;
    $self->merge_entities("release", $new_id, @old_ids);
}

sub delete_releases
{
    my ($self, @ids) = @_;
    $self->delete_entities("release", @ids);
}

sub add_events_to_collection
{
    my ($self, $collection_id, @ids) = @_;
    $self->add_entities_to_collection("event", $collection_id, @ids);
}

sub remove_events_from_collection
{
    my ($self, $collection_id, @ids) = @_;
    $self->remove_entities_from_collection("event", $collection_id, @ids);
}

sub check_event
{
    my ($self, $collection_id, $id) = @_;
    return $self->contains_entity("event", $collection_id, $id);
}

sub merge_events
{
    my ($self, $new_id, @old_ids) = @_;
    $self->merge_entities("event", $new_id, @old_ids);
}

sub delete_events
{
    my ($self, @ids) = @_;
    $self->delete_entities("event", @ids);
}

sub get_first_collection {
    my ($self, $editor_id) = @_;
    my $query = 'SELECT id FROM ' . $self->_table . ' WHERE editor = ? ORDER BY id ASC LIMIT 1';
    return $self->sql->select_single_value($query, $editor_id);
}

sub find_all_by_editor {
    my ($self, $id, $show_private, $entity_type) = @_;
    my $extra_conditions = (defined $entity_type) ? "AND ct.entity_type = '$entity_type'" : "";
    if (!$show_private) {
        $extra_conditions .= "AND editor_collection.public=true ";
    }

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_collection_type ct
                        ON editor_collection.type = ct.id
                 WHERE editor=? $extra_conditions";

    $query .= "ORDER BY musicbrainz_collate(editor_collection.name)";
    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $id);
}

sub find_all_by_entity {
    my ($self, $type, $id) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_collection_$type ce
                        ON editor_collection.id = ce.collection
                 WHERE ce.$type = ? ";

    $query .= "ORDER BY musicbrainz_collate(name)";
    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $id);
}

sub find_all_by_event
{
    my ($self, $id) = @_;
    return $self->find_all_by_entity('event', $id);
}

sub find_all_by_release
{
    my ($self, $id) = @_;
    return $self->find_all_by_entity('release', $id);
}

sub load {
    my ($self, @objs) = @_;
    load_subobjects($self, 'collection', @objs);
}

sub _insert_hook_prepare {
    my ($self, $entities) = @_;
    my $editor_id = shift @$entities;
        # A bit of a hack: first parameter is not a collection.
    return { editor_id => $editor_id };
}

around _insert_hook_make_row => sub {
    my ($orig, $self, $entity, $extra_data) = @_;
    my $row = $self->$orig($entity, $extra_data);
    $row->{editor} = $extra_data->{editor_id};
    return $row;
};

sub load_entity_count {
    my ($self, @collections) = @_;
    return unless @collections;
    my %collection_map = map { $_->id => $_ } grep { defined } @collections;
    my $query =
      'SELECT id, (' . join(' + ', map {"coalesce((SELECT count($_)
           FROM editor_collection_$_ WHERE collection = col.id), 0)"
       } entities_with('collections')) . '
           ) FROM (
              VALUES '. join(', ', ("(?::integer)") x keys %collection_map) .'
                ) col (id)';

    for my $row (@{ $self->sql->select_list_of_lists($query, keys %collection_map) }) {
        my ($id, $count) = @$row;
        $collection_map{$id}->entity_count($count);
    }
}

sub update {
    my ($self, $collection_id, $update) = @_;
    croak '$collection_id must be present and > 0' unless $collection_id > 0;
    my $row = $self->_hash_to_row($update);

    my $collection = $self->c->model('Collection')->get_by_id($collection_id);
    $self->c->model('Collection')->load_entity_count($collection);

    if (defined($row->{type}) && $collection->type_id != $row->{type}) {
        die "Cannot change the type of a non-empty collection" if $collection->entity_count != 0;
    }

    $self->sql->auto_commit;
    $self->sql->update_row('editor_collection', $row, { id => $collection_id });
}

sub delete {
    my ($self, @collection_ids) = @_;
    return unless @collection_ids;

    $self->sql->begin;

    # Remove all entities associated with the collection(s)
    map {
        $self->sql->do("DELETE FROM editor_collection_$_
            WHERE collection IN (" . placeholders(@collection_ids) . ')', @collection_ids);
    } entities_with('collections');

    # Remove collection(s)
    $self->sql->do('DELETE FROM editor_collection
                    WHERE id IN (' . placeholders(@collection_ids) . ')', @collection_ids);

    $self->sql->commit;

    return;
}

sub delete_editor {
    my ($self, $editor_id) = @_;
    $self->delete(
        @{ $self->sql->select_single_column_array(
            'SELECT id FROM editor_collection WHERE editor = ?',
            $editor_id
        ) }
    );
}

sub _hash_to_row {
    my ($self, $values) = @_;

    my %row = (
        name => $values->{name},
        public => $values->{public},
        description => $values->{description},
        type => $values->{type_id},
    );

    return \%row;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2010 Sean Burke

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
