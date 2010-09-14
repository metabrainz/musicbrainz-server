package MusicBrainz::Server::Controller::WS::1::Role::Alias;
use Moose::Role;

before 'lookup' => sub {
    my ($self, $c) = @_;

    my $entity = $c->stash->{entity};
    my $model = $self->model;

    $c->stash->{data}{aliases} = $c->model($model)->alias->find_by_entity_id($entity->id)
        if ($c->stash->{inc}->aliases);
};

1;
