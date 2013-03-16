package MusicBrainz::Server::Controller::WS::1::Role::Tags;
use Moose::Role;

use MusicBrainz::Server::Constants qw( $ACCESS_SCOPE_TAG );

before 'lookup' => sub {
    my ($self, $c) = @_;

    return unless $c->stash->{inc}->tags || $c->stash->{inc}->user_tags;
    $self->authenticate($c, $ACCESS_SCOPE_TAG) if !$c->user_exists && $c->stash->{inc}->user_tags;

    my $entity = $c->stash->{entity};
    my $model = $self->model;

    if ($c->stash->{inc}->tags) {
        my ($tags, $hits) = $c->model($model)->tags->find_tags($entity->id);
        $c->stash->{data}{tags} = $tags;
    }

    if ($c->stash->{inc}->user_tags) {
        $c->stash->{data}{user_tags} = [
            $c->model($model)->tags->find_user_tags($c->user->id, $entity->id)
        ];
    }
};

1;
