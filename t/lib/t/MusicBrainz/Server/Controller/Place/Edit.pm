package t::MusicBrainz::Server::Controller::Place::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( accept_edit html_ok );

with 't::Mechanize', 't::Context';

test 'Remove coordinates from a place' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO place (gid, name, type, coordinates)
            VALUES ('a24c9284-a9d2-428b-bacd-fa79cf9a9108', 'Sydney Opera House', 2, POINT(-33.858667,151.214028));
        SQL
    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/place/a24c9284-a9d2-428b-bacd-fa79cf9a9108/edit');
    html_ok($mech->content);
    $mech->content_contains('33.858667S, 151.214028E', 'has coordinates');
    $mech->submit_form(
        with_fields => {
            'edit-place.coordinates' => '',
        }
    );
    ok($mech->success);

    ok($mech->uri =~ qr{/place/a24c9284-a9d2-428b-bacd-fa79cf9a9108$}, 'redirected to place page');
    html_ok($mech->content);
    $mech->content_contains('Coordinates:', 'still has coordinates');
    $mech->content_contains('33.858667', 'still has latitude');

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Place::Edit');
    accept_edit($c, $edit);

    $mech->get_ok('/place/a24c9284-a9d2-428b-bacd-fa79cf9a9108', 'reload the place page');
    html_ok($mech->content);
    $mech->content_lacks('Coordinates:', 'no longer has coordinates');
    $mech->content_lacks('33.858667', 'no longer has latitude');
};

1;
