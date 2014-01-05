package MusicBrainz::Server::Controller::Role::Cleanup;
use Moose::Role;
use namespace::autoclean;

after show => sub {
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    $c->stash(
        eligible_for_cleanup => $c->model( $self->config->{model} )->is_empty($entity->id)
    )
};

1;
