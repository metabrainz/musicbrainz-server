package MusicBrainz::Server::Data::Collection;

use Moose;
use namespace::autoclean;

use Carp;
use Sql;
use MusicBrainz::Server::Entity::Collection;
use MusicBrainz::Server::Data::Utils qw(
    generate_gid
    load_subobjects
    placeholders
    query_to_list
    query_to_list_limited
);
use List::MoreUtils qw( zip );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_collection',
    column => 'collection',
    class => 'MusicBrainz::Server::Entity::CollectionSubscription'
};

sub _table
{
    return 'editor_collection';
}

sub _columns
{
    return 'editor_collection.id, gid, editor_collection.editor, name, public, description';
}

sub _id_column
{
    return 'id';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        editor_id => 'editor',
        name => 'name',
        public => 'public',
        description => 'description',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Collection';
}

sub find_by_subscribed_editor
{
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

sub add_releases_to_collection
{
    my ($self, $collection_id, @release_ids) = @_;
    return unless @release_ids;

    $self->sql->auto_commit;

    my @collection_ids = ($collection_id) x @release_ids;
    $self->sql->do("
        INSERT INTO editor_collection_release (collection, release)
           SELECT DISTINCT add.collection, add.release
             FROM (VALUES " . join(', ', ("(?::integer, ?::integer)") x @release_ids) . ") add (collection, release)
            WHERE NOT EXISTS (
              SELECT TRUE FROM editor_collection_release
              WHERE collection = add.collection AND release = add.release
              LIMIT 1
            )", zip @collection_ids, @release_ids);
}

sub remove_releases_from_collection
{
    my ($self, $collection_id, @release_ids) = @_;
    return unless @release_ids;

    $self->sql->auto_commit;
    $self->sql->do("DELETE FROM editor_collection_release
              WHERE collection = ? AND release IN (" . placeholders(@release_ids) . ")",
              $collection_id, @release_ids);
}

sub check_release
{
    my ($self, $collection_id, $release_id) = @_;

    return $self->sql->select_single_value("
        SELECT 1 FROM editor_collection_release
        WHERE collection = ? AND release = ?",
        $collection_id, $release_id) ? 1 : 0;
}

sub merge_releases
{
    my ($self, $new_id, @old_ids) = @_;

    my @ids = ($new_id, @old_ids);

    # Remove duplicate joins (ie, rows with release from @old_ids and pointing to
    # a collection that already contains $new_id)
    $self->sql->do(
        "DELETE FROM editor_collection_release
               WHERE release IN (" . placeholders(@ids) . ")
                 AND (collection, release) NOT IN (
                     SELECT DISTINCT ON (collection) collection, release
                       FROM editor_collection_release
                      WHERE release IN (" . placeholders(@ids) . ")
                 )",
        @ids, @ids);

    # Move all remaining joins to the new release
    $self->sql->do("UPDATE editor_collection_release SET release = ?
              WHERE release IN (".placeholders(@ids).")",
              $new_id, @ids);
}

sub delete_releases
{
    my ($self, @ids) = @_;

    $self->sql->do("DELETE FROM editor_collection_release
              WHERE release IN (".placeholders(@ids).")", @ids);
}

sub find_by_editor
{
    my ($self, $id, $show_private, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE editor=? ";

    if (!$show_private) {
        $query .= "AND public=true ";
    }

    $query .= "ORDER BY musicbrainz_collate(name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $id, $offset || 0);
}

sub get_first_collection
{
    my ($self, $editor_id) = @_;
    my $query = 'SELECT id FROM ' . $self->_table . ' WHERE editor = ? ORDER BY id ASC LIMIT 1';
    return $self->sql->select_single_value($query, $editor_id);
}

sub find_all_by_editor
{
    my ($self, $id) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE editor=? ";

    $query .= "ORDER BY musicbrainz_collate(name)";
    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $id);
}

sub find_all_by_release
{
    my ($self, $id) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_collection_release cr
                        ON editor_collection.id = cr.collection
                 WHERE cr.release = ? ";

    $query .= "ORDER BY musicbrainz_collate(name)";
    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $id);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'collection', @objs);
}

sub insert
{
    my ($self, $editor_id, @collections) = @_;
    my $class = $self->_entity_class;
    my @created;
    for my $collection (@collections) {
        my $row = $self->_hash_to_row($collection);
        $row->{editor} = $editor_id;
        $row->{gid} = $collection->{gid} || generate_gid();

        push @created, $class->new(
            id => $self->sql->insert_row('editor_collection', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @created > 1 ? @created : $created[0];
}

sub load_release_count {
    my ($self, @collections) = @_;
    return unless @collections;
    my %collection_map = map { $_->id => $_ } grep { defined } @collections;
    my $query =
        'SELECT id, coalesce(
           (SELECT count(release)
              FROM editor_collection_release
             WHERE collection = col.id), 0)
           FROM (
              VALUES '. join(', ', ("(?::integer)") x keys %collection_map) .'
                ) col (id)';

    $self->sql->select($query, keys %collection_map);
    while (my ($id, $count) = $self->sql->next_row) {
        $collection_map{$id}->release_count($count);
    }
    $self->sql->finish;
}

sub update
{
    my ($self, $collection_id, $update) = @_;
    croak '$collection_id must be present and > 0' unless $collection_id > 0;
    my $row = $self->_hash_to_row($update);

    $self->sql->auto_commit;
    $self->sql->update_row('editor_collection', $row, { id => $collection_id });
}

sub delete
{
    my ($self, @collection_ids) = @_;
    return unless @collection_ids;

    $self->sql->begin;

    # Remove all releases associated with the collection(s)
    $self->sql->do('DELETE FROM editor_collection_release
                    WHERE collection IN (' . placeholders(@collection_ids) . ')', @collection_ids);

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

sub _hash_to_row
{
    my ($self, $values) = @_;

    my %row = (
        name => $values->{name},
        public => $values->{public},
        description => $values->{description}
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
