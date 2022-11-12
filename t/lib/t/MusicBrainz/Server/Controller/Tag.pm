package t::MusicBrainz::Server::Controller::Tag;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( html_ok );

with 't::Context', 't::Mechanize';

test 'Can view tags' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $test->mech->get_ok('/tag/musical');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Tag .musical.});

    $test->mech->get_ok('/tag/musical/artist');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Artist});
    $test->mech->get_ok('/tag/not-used/artist');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 artists found});

    $test->mech->get_ok('/tag/musical/label');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Warp Records});
    $test->mech->get_ok('/tag/not-used/label');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 labels found});

    $test->mech->get_ok('/tag/musical/recording');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Dancing Queen.*?ABBA});
    $test->mech->get_ok('/tag/not-used/recording');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 recordings found});

    $test->mech->get_ok('/tag/musical/release-group');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Arrival.*?ABBA});
    $test->mech->get_ok('/tag/not-used/release-group');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 release groups found});

    $test->mech->get_ok('/tag/musical/work');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Dancing Queen});
    $test->mech->get_ok('/tag/not-used/work');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 works found});

    $test->mech->get('/tag/not-found');
    html_ok($test->mech->content);
    is($test->mech->status(), 404);

    $test->mech->get_ok('/tag/hip-hop%2Frap/');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Tag “hip-hop/rap”}, 'contains hip-hop/rap tag');
};

1;
