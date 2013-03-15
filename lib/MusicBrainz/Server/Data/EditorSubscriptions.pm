package MusicBrainz::Server::Data::EditorSubscriptions;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::Sql';

my @subscribable_models = qw(
    Artist
    Collection
    Editor
    Label
);

sub get_all_subscriptions
{
    my ($self, $editor_id) = @_;
    return map {
        $self->c->model($_)->subscription->get_subscriptions($editor_id)
    } @subscribable_models;
}

sub update_subscriptions
{
    my ($self, $max_id, $editor_id) = @_;

    $self->sql->begin;
    $self->sql->do(
        "DELETE FROM $_
          WHERE editor = ? AND (deleted_by_edit != 0 OR merged_by_edit != 0)",
        $editor_id
    ) for qw(
        editor_subscribe_artist
        editor_subscribe_label
    );

    # Remove subscriptions to deleted or private collections
    $self->sql->do(
        "DELETE FROM editor_subscribe_collection
          WHERE editor = ? AND NOT available",
        $editor_id);

    $self->sql->do(
        "UPDATE $_ SET last_edit_sent = ? WHERE editor = ?",
        $max_id, $editor_id
    ) for qw(
        editor_subscribe_label
        editor_subscribe_artist
        editor_subscribe_editor
        editor_subscribe_collection
    );
    $self->sql->commit;
}

sub delete_editor {
    my ($self, $editor_id) = @_;
    for my $table (qw( editor_subscribe_artist
                       editor_subscribe_collection
                       editor_subscribe_editor
                       editor_subscribe_label )) {
        $self->sql->do("DELETE FROM $table WHERE editor = ?", $editor_id);
    }
}

1;
