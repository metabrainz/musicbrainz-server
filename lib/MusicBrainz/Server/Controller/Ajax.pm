package MusicBrainz::Server::Controller::Ajax;
use Moose;

BEGIN { extends 'Catalyst::Controller' };

use JSON qw( encode_json );
use MusicBrainz::Server::FilterUtils qw(
    create_artist_events_form
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
    create_artist_works_form
);

sub filter_artist_events_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    my $form = create_artist_events_form($c, $artist_id);

    $c->res->body(encode_json($form->TO_JSON));
    $c->res->content_type('application/json; charset=utf-8');
}

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
