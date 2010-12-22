package MusicBrainz::Server::Edit::Role::MergeSubscription;
use Moose::Role;
use namespace::autoclean;

requires 'subscription_model', '_entity_ids';

after 'accept' => sub {
    my $self = shift;
    $self->subscription_model->merge($self->id, $self->_old_ids);
};

1;
