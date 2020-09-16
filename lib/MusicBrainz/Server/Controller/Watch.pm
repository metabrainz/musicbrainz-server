package MusicBrainz::Server::Controller::Watch;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

sub list : Local RequireAuth SecureForm {
    my ($self, $c) = @_;

    if ($c->form_posted && $c->validate_csrf_token) {
        my $remove_s = $c->req->params->{remove};
        my @remove = ref($remove_s) ? @$remove_s : ( $remove_s );

        $c->model('WatchArtist')->stop_watching_artist(
            editor_id => $c->user->id,
            artist_ids => \@remove
        );
    }

    $c->stash(
        watching => [
            $c->model('WatchArtist')->find_watched_artists($c->user->id)
        ]
    );
}

__PACKAGE__->meta->make_immutable;
1;
