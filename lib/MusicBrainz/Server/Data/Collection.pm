package MusicBrainz::Server::Data::Collection;

use Moose;
use namespace::autoclean;

use Carp;
use Sql;
use MusicBrainz::Server::Entity::Collection;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    placeholders
);
use List::AllUtils qw( any uniq uniq_by zip );
use MusicBrainz::Server::Constants qw( entities_with );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityModelClass';
with 'MusicBrainz::Server::Data::Role::GetByGID';
with 'MusicBrainz::Server::Data::Role::MainTable';
with 'MusicBrainz::Server::Data::Role::GID';
with 'MusicBrainz::Server::Data::Role::GIDRedirect';
with 'MusicBrainz::Server::Data::Role::Name';
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
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                    JOIN editor_subscribe_collection s ON editor_collection.id = s.collection
                 WHERE s.editor = ? AND s.available
                 ORDER BY name COLLATE musicbrainz, editor_collection.id';
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
}

sub add_entities_to_collection {
    my ($self, $type, $collection_id, @ids) = @_;
    return unless @ids;

    $self->sql->auto_commit;

    my @collection_ids = ($collection_id) x @ids;
    $self->sql->do("
        INSERT INTO editor_collection_$type (collection, $type)
           SELECT DISTINCT add.collection, add.$type
             FROM (VALUES " . join(', ', ('(?::integer, ?::integer)') x @ids) . ") add (collection, $type)
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
              WHERE collection = ? AND $type IN (" . placeholders(@ids) . ')',
              $collection_id, @ids);
}

sub contains_entity {
    my ($self, $type, $collection_id, $id) = @_;

    return $self->sql->select_single_value("
        SELECT 1 FROM editor_collection_$type
        WHERE collection = ? AND $type = ?",
        $collection_id, $id) ? 1 : 0;
}

sub is_collection_collaborator {
    my ($self, $user_id, $collection_id) = @_;

    return $self->sql->select_single_value(
        'SELECT 1 FROM editor_collection WHERE (id = $1 AND editor = $2) OR 
            EXISTS (SELECT 1 FROM editor_collection_collaborator ecc
                WHERE ecc.collection = $1 AND ecc.editor = $2)',
        $collection_id, $user_id,
    );
}

sub is_empty {
    my ($self, $type, $collection_id) = @_;

    my $non_empty = $self->sql->select_single_value(
        "SELECT 1 FROM editor_collection_$type WHERE collection = ?",
        $collection_id,
    );

    return $non_empty ? 0 : 1;
}

sub merge {
    my ($self, $new_id, $old_ids, $user_id) = @_;

    my @ids = ($new_id, @$old_ids);

    my @collections = values %{ $self->c->model('Collection')->get_by_ids(@ids) };
    my @collection_owners = uniq map { $_->editor_id } @collections;
    if (any { $_ != $user_id } @collection_owners) {
        confess('Attempt to merge collections by a different user');
    }

    $self->c->model('CollectionType')->load(@collections);
    my @entity_types = uniq map { $_->type->item_entity_type } @collections;

    if (@entity_types > 1) {
        confess('Attempt to merge collections of different entity types');
    }

    my $type = $entity_types[0];

    # Update duplicate entities: for all entities that exist in multiple
    # collections, standardize the data to that what we want to keep.
    $self->sql->do(
        "UPDATE editor_collection_$type ec
         SET added = x.added, comment = x.comment
         FROM (
            SELECT $type, min(added) AS added, string_agg(comment, '\n\n-------\n\n') AS comment
            FROM editor_collection_$type
            WHERE collection = any(?)
            GROUP BY $type
         ) x 
         WHERE x.$type = ec.$type AND ec.collection = any(?)",
        \@ids, \@ids);

    # Move all entities to the destination collection, ignore repeats
    $self->sql->do(
        "INSERT INTO editor_collection_$type
         SELECT ? AS collection, $type, added, position, comment
         FROM editor_collection_$type ec1
         WHERE ec1.collection = any(?)
         ON CONFLICT (collection, $type) DO NOTHING",
        $new_id, $old_ids);

    # Remove entries for old collections
    $self->sql->do(
        "DELETE FROM editor_collection_$type
         WHERE collection = any(?)",
        $old_ids);

    for my $collection (@collections) {
        $self->c->model('Editor')->load_for_collection($collection);
    }

    my @collaborators = uniq_by { $_->id } map { $_->all_collaborators } @collections;

    # Move all collaborators to the destination collection
    $self->set_collaborators(
        $new_id, \@collaborators
    ) if @collaborators;

    # Remove all collaborators from the collection(s) being merged
    $self->sql->do('DELETE FROM editor_collection_collaborator
                    WHERE collection IN (' . placeholders(@$old_ids) . ')', @$old_ids);

    # Append all descriptions to the destination one, for user improvement if needed
    my $new_description = join("\n\n-------\n\n",
                          uniq
                          grep { $_ ne '' }
                          map { $_->description }
                          @collections);
    if ($new_description ne '') {
        $self->sql->do('UPDATE editor_collection SET description = ?
                WHERE id = ?',
                $new_description,
                $new_id);
    }

    # Finally, delete the now empty collections
    $self->_delete_and_redirect_gids('editor_collection', $new_id, @$old_ids);

    return 1;
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
                      WHERE $type IN (" . placeholders(@ids) . ')
                 )',
        @ids, @ids);

    # Move all remaining joins to the new release
    $self->sql->do("UPDATE editor_collection_$type SET $type = ?
              WHERE $type IN (".placeholders(@ids).')',
              $new_id, @ids);
}

sub delete_entities {
    my ($self, $type, @ids) = @_;

    $self->sql->do("DELETE FROM editor_collection_$type
              WHERE $type IN (".placeholders(@ids).')', @ids);
}

sub find_by {
    my ($self, $opts, $limit, $offset) = @_;

    my (@conditions, @args);

    if (my $editor_id = $opts->{editor_id}) {
        if ($opts->{with_collaborations}) {
            push @conditions, '(editor_collection.editor = ? OR
                               EXISTS (SELECT 1 FROM editor_collection_collaborator ecc
                               WHERE ecc.collection = editor_collection.id AND ecc.editor = ?))';
            push @args, $editor_id, $editor_id;
        } else {
            push @conditions, 'editor_collection.editor = ?';
            push @args, $editor_id;
        }
    }

    if (my $entity_type = $opts->{entity_type}) {
        push @conditions,
            'EXISTS (SELECT 1 FROM editor_collection_type ct' .
                    ' WHERE ct.id = editor_collection.type AND ct.entity_type = ?)';
        push @args, $entity_type;

        if (my $entity_id = $opts->{entity_id}) {
            push @conditions,
                "EXISTS (SELECT 1 FROM editor_collection_$entity_type ce" .
                        " WHERE editor_collection.id = ce.collection AND ce.$entity_type = ?)";
            push @args, $entity_id;
        }
    }

    if (my $editor_id = $opts->{collaborator_id}) {
        push @conditions, 'EXISTS (SELECT 1 FROM editor_collection_collaborator ecc
                           WHERE ecc.collection = editor_collection.id AND ecc.editor = ?)';
        push @args, $editor_id;
    }

    if (my $editor_id = $opts->{show_private}) {
        push @conditions, '(editor_collection.public = true OR editor_collection.editor = ? OR
                            EXISTS (SELECT 1 FROM editor_collection_collaborator ecc
                            WHERE ecc.collection = editor_collection.id AND ecc.editor = ?))';
        push @args, $editor_id, $editor_id;
    } else {
        push @conditions, 'editor_collection.public = true';
    }

    my $query =
        'SELECT ' . $self->_columns .
        '  FROM ' . $self->_table . ' ' .
        ' WHERE ' . join(' AND ', @conditions) .
        ' ORDER BY editor_collection.name COLLATE musicbrainz, editor_collection.id';

    if (defined $limit) {
        return $self->query_to_list_limited($query, \@args, $limit, $offset);
    } else {
        my @result = $self->query_to_list($query, \@args);
        return (\@result, scalar @result);
    }
}

sub get_hidden_collection_count {
    my ($self, $opts) = @_;

    my (@conditions, @args);

    push @conditions, 'editor_collection.public = false';
    my $entity_type = $opts->{entity_type};
    push @conditions, <<~'SQL';
        EXISTS (
                SELECT 1
                  FROM editor_collection_type ct
                 WHERE ct.id = editor_collection.type
                   AND ct.entity_type = ?
               )
        SQL
    push @args, $entity_type;

    my $entity_id = $opts->{entity_id};
    push @conditions, <<~"SQL";
        EXISTS (
                SELECT 1
                  FROM editor_collection_$entity_type ce
                 WHERE editor_collection.id = ce.collection
                   AND ce.$entity_type = ?
               )
        SQL
    push @args, $entity_id;

    if (my $editor_id = $opts->{editor_id}) {
        push @conditions, 'editor_collection.editor != ?';
        push @conditions, <<~'SQL';
            NOT EXISTS (
                        SELECT 1
                          FROM editor_collection_collaborator ecc
                         WHERE ecc.collection = editor_collection.id
                           AND ecc.editor = ?
                       )
            SQL
        push @args, $editor_id, $editor_id;
    }

    my $query =
        'SELECT count(*) ' .
        '  FROM ' . $self->_table . ' ' .
        ' WHERE ' . join(' AND ', @conditions);

    return $self->sql->select_single_value($query, @args);

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

sub _insert_hook_after_each {
    my ($self, $created, $collection) = @_;

    $self->set_collaborators(
        $created->{id}, $collection->{collaborators}
    ) if $collection->{collaborators};
}

sub load_entity_count {
    my ($self, @collections) = @_;
    return unless @collections;
    my %collection_map = map { $_->id => $_ } grep { defined } @collections;
    my $query =
      'SELECT id, (' . join(' + ', map {"coalesce((SELECT count($_)
           FROM editor_collection_$_ WHERE collection = col.id), 0)"
       } entities_with('collections')) . '
           ) FROM (
              VALUES '. join(', ', ('(?::integer)') x keys %collection_map) .'
                ) col (id)';

    for my $row (@{ $self->sql->select_list_of_lists($query, keys %collection_map) }) {
        my ($id, $count) = @$row;
        $collection_map{$id}->entity_count($count);
    }
}

sub update {
    my ($self, $collection_id, $update) = @_;
    croak '$collection_id must be present and > 0' unless $collection_id > 0;

    $self->set_collaborators(
        $collection_id, $update->{collaborators}
    ) if $update->{collaborators};

    my $row = $self->_hash_to_row($update);
    my $collection = $self->get_by_id($collection_id);
    $self->c->model('CollectionType')->load($collection);
    my $old_entity_type = $collection->type->item_entity_type;

    if (defined($row->{type}) && $collection->type_id != $row->{type} &&
            !$self->is_empty($old_entity_type, $collection->id)) {
        my $new_type = $self->c->model('CollectionType')->get_by_id($row->{type});

        die 'The collection type must match the type of entities it contains.'
            if $old_entity_type ne $new_type->item_entity_type;
    }

    $self->sql->auto_commit;
    $self->sql->update_row('editor_collection', $row, { id => $collection_id });
}

sub delete {
    my ($self, @collection_ids) = @_;
    return unless @collection_ids;

    $self->sql->begin;
    $self->remove_gid_redirects(@collection_ids);

    # Remove all entities associated with the collection(s)
    map {
        $self->sql->do("DELETE FROM editor_collection_$_
            WHERE collection IN (" . placeholders(@collection_ids) . ')', @collection_ids);
    } entities_with('collections');

    # Remove all collaborators associated with the collection(s)
    $self->sql->do('DELETE FROM editor_collection_collaborator
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

sub set_collaborators {
    my ($self, $collection_id, $collaborators) = @_;

    $self->sql->begin;

    $self->sql->do('DELETE FROM editor_collection_collaborator WHERE collection = ?', $collection_id);
    $self->sql->insert_many(
        'editor_collection_collaborator',
        map +{
            collection => $collection_id,
            editor     => $_->{id},
        }, @$collaborators
    );

    # Remove non-owner, no-longer-collaborator subscriptions if collection is private
    $self->sql->do(<<~'SQL', $collection_id);
        UPDATE editor_subscribe_collection esc
           SET available = FALSE,
               last_seen_name = ec.name
          FROM editor_collection ec
         WHERE esc.collection = ?
           AND esc.collection = ec.id
           AND ec.public IS FALSE
           AND esc.available IS TRUE
           AND esc.editor != ec.editor
           AND esc.editor NOT IN (SELECT editor
                                    FROM editor_collection_collaborator
                                   WHERE collection = esc.collection)
        SQL

    $self->sql->commit;
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2010 Sean Burke
Copyright (C) 2015 Jesse Weinstein

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
