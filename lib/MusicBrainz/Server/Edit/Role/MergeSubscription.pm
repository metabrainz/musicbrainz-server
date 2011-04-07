package MusicBrainz::Server::Edit::Role::MergeSubscription;
use Moose::Role;
use namespace::autoclean;

requires 'subscription_model', '_entity_ids', 'do_merge';

after do_merge => sub {
    my $self = shift;
    $self->subscription_model->merge($self->id, $self->_old_ids);
};

1;
