package MusicBrainz::Server::Controller::Watch;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

sub list : Local RequireAuth {
    my ($self, $c) = @_;
    $c->stash(
        watching => [
            $c->model('WatchArtist')->find_watched_artists($c->user->id)
        ]
    );
}

__PACKAGE__->meta->make_immutable;
1;
