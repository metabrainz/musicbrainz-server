package MusicBrainz::Server::Data::Subscription;

use Moose;
use namespace::autoclean;
use Sql;
use MusicBrainz::Server::Data::Utils qw(
    is_special_artist
    is_special_label
    placeholders
    query_to_list
);

with 'MusicBrainz::Server::Data::Role::NewFromRow';
with 'MusicBrainz::Server::Data::Role::Sql';

has 'table' => (
    is => 'ro',
    isa => 'Str'
);

has 'column' => (
    is => 'ro',
    isa => 'Str'
);

has 'class' => (
    is => 'ro',
    isa => 'Str',
);

sub _entity_class {
    my $self = shift;
    return $self->class;
}

sub _column_mapping {
    my $self = shift;
    return {
        id => 'id',
        $self->column . '_id' => $self->column,
        'last_edit_sent' => 'last_edit_sent',
        'deleted_by_edit' => 'deleted_by_edit',
        'merged_by_edit' => 'merged_by_edit',
        'editor_id' => 'editor',
        'available' => 'available',
        'last_seen_name' => 'last_seen_name',
    };
}

sub subscribe
{
    my ($self, $user_id, $id) = @_;

    return if $self->column eq 'artist' && is_special_artist($id);
    return if $self->column eq 'label'  && is_special_label($id);

    my $table = $self->table;
    my $column = $self->column;

    Sql::run_in_transaction(sub {

        return if $self->sql->select_single_value("
            SELECT id FROM $table WHERE editor = ? AND $column = ?",
            $user_id, $id);

        my $max_edit_id = $self->c->model('Edit')->get_max_id() || 0;
        $self->sql->do("INSERT INTO $table (editor, $column, last_edit_sent)
                  VALUES (?, ?, ?)", $user_id, $id, $max_edit_id);

    }, $self->c->sql);
}

sub unsubscribe
{
    my ($self, $user_id, @ids) = @_;

    my $table = $self->table;
    my $column = $self->column;

    Sql::run_in_transaction(sub {

        $self->sql->do("
            DELETE FROM $table WHERE editor = ? AND $column IN (".
            placeholders(@ids) . ")",
            $user_id, @ids);

    }, $self->c->sql);
}

sub check_subscription
{
    my ($self, $user_id, $id) = @_;

    my $table = $self->table;
    my $column = $self->column;

    return $self->sql->select_single_value("
        SELECT 1 FROM $table
        WHERE editor = ? AND $column = ?",
        $user_id, $id) ? 1 : 0;
}

sub find_subscribed_editors
{
    my ($self, $entity_id) = @_;

    require MusicBrainz::Server::Data::Editor;
    my $table = $self->table;
    my $column = $self->column;

    my $extra_cond = "";

    $extra_cond = " AND s.available"
        if ($column eq "collection");

    my $query = "
        SELECT " . MusicBrainz::Server::Data::Editor->_columns . "
        FROM " . MusicBrainz::Server::Data::Editor->_table . "
            JOIN $table s ON editor.id = s.editor
        WHERE s.$column = ?" . $extra_cond . "
        ORDER BY editor.name, editor.id";

    return query_to_list(
        $self->c->sql, sub { MusicBrainz::Server::Data::Editor->_new_from_row(@_) },
        $query, $entity_id);
}

sub get_subscribed_editor_count
{
    my ($self, $entity_id) = @_;

    my $table = $self->table;
    my $column = $self->column;

    return $self->sql->select_single_value("SELECT count(*) FROM $table
                                    WHERE $column = ?", $entity_id);
}

sub get_subscriptions
{
    my ($self, $editor_id) = @_;
    my $query = 'SELECT * FROM ' . $self->table . ' WHERE editor = ?';
    return query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $editor_id);
}

sub merge
{
    my ($self, $edit_id, @ids) = @_;

    my $table = $self->table;
    my $column = $self->column;

    $self->sql->do("UPDATE $table SET merged_by_edit = ?
              WHERE $column IN (".placeholders(@ids).")",
              $edit_id, @ids);
}

sub merge_entities
{
    my ($self, $new_id, @old_ids) = @_;

    my $column = $self->column;
    my $table = $self->table;

    return if $self->column eq 'artist' && is_special_artist($new_id);
    return if $self->column eq 'label'  && is_special_label($new_id);

    $self->sql->do(
        "INSERT INTO $table (editor, $column, last_edit_sent)
         SELECT DISTINCT editor, ?::INTEGER, max(last_edit_sent)
           FROM $table t1
          WHERE $column IN (" . placeholders(@old_ids) . ")
            AND NOT EXISTS (
                SELECT 1 FROM $table t2
                 WHERE t2.$column = ? AND t2.editor = t1.editor
                )
       GROUP BY editor, $column",
        $new_id, @old_ids, $new_id
    );
}

sub delete
{
    my ($self, $edit_id, @ids) = @_;

    my $table = $self->table;
    my $column = $self->column;

    $self->sql->do("UPDATE $table SET deleted_by_edit = ?
               WHERE $column IN (".placeholders(@ids).")", $edit_id, @ids);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
