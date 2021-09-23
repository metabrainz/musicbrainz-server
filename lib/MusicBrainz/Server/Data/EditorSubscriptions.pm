package MusicBrainz::Server::Data::EditorSubscriptions;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( entities_with );

with 'MusicBrainz::Server::Data::Role::Sql';

sub get_all_subscriptions
{
    my ($self, $editor_id) = @_;
    return map {
        $self->c->model($_)->subscription->get_subscriptions($editor_id)
    } entities_with('subscriptions', take => 'model');
}

sub update_subscriptions
{
    my ($self, $max_id, $editor_id) = @_;

    $self->sql->begin;

    $self->sql->do("DELETE FROM $_ WHERE editor = ?", $editor_id)
        for entities_with(['subscriptions', 'deleted'],
                          take => sub { 'editor_subscribe_' . (shift) . '_deleted' });

    # Remove subscriptions to deleted or private collections
    $self->sql->do(
        'DELETE FROM editor_subscribe_collection
          WHERE editor = ? AND NOT available',
        $editor_id);

    $self->sql->do(
        "UPDATE $_ SET last_edit_sent = ? WHERE editor = ?",
        $max_id, $editor_id
    ) for entities_with('subscriptions', take => sub { 'editor_subscribe_' . (shift) });
    $self->sql->commit;
}

sub delete_editor {
    my ($self, $editor_id) = @_;
    $self->sql->do("DELETE FROM $_ WHERE editor = ?", $editor_id)
        for entities_with('subscriptions', take => sub { 'editor_subscribe_' . (shift) });
}

1;
