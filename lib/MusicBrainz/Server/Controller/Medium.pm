package MusicBrainz::Server::Controller::Medium;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

sub base : Chained('/') PathPart('medium') CaptureArgs(1) {
    my ($self, $c, $medium_id) = @_;

    my $user_id = $c->user->id if $c->user_exists;
    my $medium = $c->model('Medium')->get_by_id($medium_id);

    $c->model('Medium')->load_related_info($user_id, $medium);
    $c->stash->{medium} = $medium;
}

sub fragments : Chained('base') PathPart('fragments') {
    my ($self, $c) = @_;

    $c->stash->{template} = 'components/medium-fragments.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
