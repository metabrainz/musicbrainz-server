package MusicBrainz::Server::Controller::Ajax;
BEGIN { use Moose; extends 'Catalyst::Controller' };

use JSON qw( encode_json );
use MusicBrainz::Server::FilterUtils qw(
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
    create_artist_works_form
);

sub filter_artist_release_groups_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    my $form = create_artist_release_groups_form($c, $artist_id);

    $c->res->body(encode_json($form->TO_JSON));
    $c->res->content_type('application/json; charset=utf-8');
}

sub filter_artist_releases_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    my $form = create_artist_releases_form($c, $artist_id);

    $c->res->body(encode_json($form->TO_JSON));
    $c->res->content_type('application/json; charset=utf-8');
}

sub filter_artist_recordings_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    my $form = create_artist_recordings_form($c, $artist_id);

    $c->res->body(encode_json($form->TO_JSON));
    $c->res->content_type('application/json; charset=utf-8');
}

sub filter_artist_works_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    my $form = create_artist_works_form($c, $artist_id);

    $c->res->body(encode_json($form->TO_JSON));
    $c->res->content_type('application/json; charset=utf-8');
}

1;
