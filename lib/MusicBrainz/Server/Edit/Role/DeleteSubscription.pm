package MusicBrainz::Server::Edit::Role::DeleteSubscription;
use Moose::Role;
use namespace::autoclean;

requires '_delete_model', 'subscription_model', 'entity_id';

around accept => sub {
    my ($orig, $self, @args) = @_;

    my @editors =
        map { $_->{editor} }
            @{ $self->subscription_model->delete($self->entity_id) };
    my $artist = $self->c->model($self->_delete_model)->get_by_id($self->entity_id);

    $self->$orig(@args);

    $self->subscription_model->log_deletion_for_editors($self->id, $artist->gid, @editors);
};

1;
