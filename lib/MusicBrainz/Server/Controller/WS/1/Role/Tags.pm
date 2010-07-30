package MusicBrainz::Server::Controller::WS::1::Role::Tags;
use Moose::Role;

before 'lookup' => sub {
    my ($self, $c) = @_;

    return unless $c->stash->{inc}->tags;

    my $entity = $c->stash->{entity};
    my $model = $self->model;

    my ($tags, $hits) = $c->model($model)->tags->find_tags($entity->id);
    $c->stash->{data}{tags} = $tags;
};

1;
