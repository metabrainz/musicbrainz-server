package t::MusicBrainz::Server::Controller::WS::js::CheckLogin;
use strict;
use warnings;

use Test::More;
use Test::Routine;
use JSON;
use MusicBrainz::Server::Test;

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok('/ws/js/check-login');
    $test->mech->header_is('Cache-Control', 'no-store');
    $test->mech->header_is('Pragma', 'no-cache');

    my $json = JSON->new;
    my $data = $json->decode($mech->content);
    is($data->{id}, undef, 'id is null if not logged in');
    is($data->{name}, undef, 'name is null if not logged in');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/ws/js/check-login');
    $test->mech->header_is('Cache-Control', 'no-store');
    $test->mech->header_is('Pragma', 'no-cache');

    $data = $json->decode($mech->content);
    is($data->{id}, 1, 'id is set if logged in');
    is($data->{name}, 'new_editor', 'name is set if logged in');
};

1;
