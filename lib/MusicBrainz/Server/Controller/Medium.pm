package MusicBrainz::Server::Controller::Medium;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Medium',
    entity_name => 'medium'
};

sub base : Chained('/') PathPart('medium') CaptureArgs(0) { }

after load => sub {
    my ($self, $c) = @_;

    my $user_id = $c->user->id if $c->user_exists;
    $c->model('Medium')->load_related_info($user_id, $c->stash->{medium});
};

sub fragments : Chained('load') PathPart('fragments') {
    my ($self, $c) = @_;

    $c->stash->{template} = 'components/medium-fragments.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
