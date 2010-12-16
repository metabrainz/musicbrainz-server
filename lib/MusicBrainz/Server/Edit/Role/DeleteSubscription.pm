package MusicBrainz::Server::Edit::Role::DeleteSubscription;
use Moose::Role;
use namespace::autoclean;

requires 'subscription_model', 'entity_id';

after 'accept' => sub {
    my $self = shift;
    $self->subscription_model->delete($self->id, $self->entity_id);
};

1;
