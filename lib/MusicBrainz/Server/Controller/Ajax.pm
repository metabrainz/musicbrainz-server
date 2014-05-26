package MusicBrainz::Server::Controller::Ajax;
BEGIN { use Moose; extends 'Catalyst::Controller' };

use MusicBrainz::Server::FilterUtils qw(
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
);

sub filter_artist_release_groups_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    create_artist_release_groups_form($c, $artist_id);

    $c->stash(template => 'components/filter-form.tt');
}

sub filter_artist_releases_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    create_artist_releases_form($c, $artist_id);

    $c->stash(template => 'components/filter-form.tt');
}

sub filter_artist_recordings_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    create_artist_recordings_form($c, $artist_id);

    $c->stash(template => 'components/filter-form.tt');
}

1;
