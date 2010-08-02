package MusicBrainz::Server::Controller::WS::1::Role::Rating;
use Moose::Role;

before 'lookup' => sub {
    my ($self, $c) = @_;

    return unless $c->stash->{inc}->ratings;

    my $entity = $c->stash->{entity};
    my $model = $self->model;

    $c->model($model)->load_meta($entity);
};

1;
