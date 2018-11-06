package MusicBrainz::Server::Controller::Role::Cleanup;
use Moose::Role;
use namespace::autoclean;

after show => sub {
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    my $eligible_for_cleanup = $c->model( $self->config->{model} )->is_empty($entity->id);
    $c->stash->{component_props}{eligibleForCleanup} = $eligible_for_cleanup;
    $c->stash(
        eligible_for_cleanup => $eligible_for_cleanup
    )
};

1;
