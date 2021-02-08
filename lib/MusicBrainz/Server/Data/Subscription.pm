package MusicBrainz::Server::Data::Subscription;
use Moose;
use namespace::autoclean;

use Class::Load qw( load_class );
use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_MERGE
    $EDIT_ARTIST_DELETE
    $EDIT_LABEL_MERGE
    $EDIT_LABEL_DELETE
    $EDIT_SERIES_MERGE
    $EDIT_SERIES_DELETE
);
use MusicBrainz::Server::Data::Utils qw(
    is_special_artist
    is_special_label
    placeholders
);
use Sql;

with 'MusicBrainz::Server::Data::Role::NewFromRow';
with 'MusicBrainz::Server::Data::Role::QueryToList';
with 'MusicBrainz::Server::Data::Role::Sql';

has 'table' => (
    is => 'ro',
    isa => 'Str'
);

has 'column' => (
    is => 'ro',
    isa => 'Str'
);

has 'active_class' => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has 'deleted_class' => (
    is => 'ro',
    isa => 'Maybe[Str]',
);

sub _entity_class {
    my $self = shift;
    return $self->active_class;
}

sub _column_mapping {
    my $self = shift;
    return {
        id => 'id',
        $self->column . '_id' => $self->column,
        'last_edit_sent' => 'last_edit_sent',
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

        my $max_edit_id = $self->c->model('Edit')->get_max_id();
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

    my $editor_model = $self->c->model('Editor');
    my $query = "
        SELECT " . $editor_model->_columns . "
        FROM " . $editor_model->_table . "
            JOIN $table s ON editor.id = s.editor
        WHERE s.$column = ?" . $extra_cond . "
        ORDER BY editor.name, editor.id";

    $editor_model->query_to_list($query, [$entity_id]);
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
    my $table = $self->table;
    my $column = $self->column;

    load_class($self->active_class);
    my @subscriptions = $self->query_to_list(
        "SELECT * FROM $table WHERE editor = ?",
        [$editor_id],
    );

    if (my $deleted_class = $self->deleted_class) {
        load_class($self->deleted_class);

        push @subscriptions, $self->query_to_list(
            "SELECT
               sub.editor, del.data->>'last_known_name' AS last_known_name,
               del.data->>'last_known_comment' AS last_known_comment, deleted_by,
               CASE
                 WHEN edit.type = any(?) THEN 'merged'
                 WHEN edit.type = any(?) THEN 'deleted'
               END AS reason
             FROM ${table}_deleted sub
             JOIN deleted_entity del USING (gid)
             JOIN edit ON (edit.id = deleted_by)
             WHERE sub.editor = ?",
            [
                [$EDIT_ARTIST_MERGE, $EDIT_LABEL_MERGE, $EDIT_SERIES_MERGE],
                [$EDIT_ARTIST_DELETE, $EDIT_LABEL_DELETE, $EDIT_SERIES_DELETE],
                $editor_id,
            ],
            sub {
                my ($model, $row) = @_;

                $deleted_class->new(
                    edit_id => $row->{deleted_by},
                    editor_id => $row->{editor},
                    last_known_name => $row->{last_known_name},
                    last_known_comment => $row->{last_known_comment},
                    reason => $row->{reason},
                );
            },
        );
    }

    return @subscriptions;
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

sub transfer_to_merge_target
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
    my ($self, @ids) = @_;

    my $table = $self->table;
    my $column = $self->column;

    return $self->sql->select_list_of_hashes(
        "DELETE FROM $table WHERE $column = any(?)
         RETURNING editor, $column",
        \@ids
    );
}

sub log_deletion_for_editors {
    my ($self, $edit_id, $gid, @editors) = @_;
    $self->log_deletions(
        $edit_id,
        map +{
            gid => $gid,
            editor => $_
        }, @editors
    );
}

sub log_deletions {
    my ($self, $edit_id, @deletions) = @_;
    $self->sql->insert_many(
        $self->table . '_deleted',
        map +{
            %$_,
            deleted_by => $edit_id,
        }, @deletions
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
