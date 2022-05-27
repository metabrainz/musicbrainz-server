package t::MusicBrainz::Server::Controller::Rating;
use Test::Routine;
use Test::More;
use utf8;

with 't::Context', 't::Mechanize';

test 'Can rate' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get('/rating/rate/?entity_type=label&entity_id=2&rating=100');
    is ($mech->status, 200);
};

test 'Cannot rate without a confirmed email address' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $c->model('Editor')->insert({
        name => 'iwannarate',
        password => 'password'
    });

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'iwannarate', password => 'password' } );

    $mech->get('/rating/rate/?entity_type=label&entity_id=2&rating=100');
    is ($mech->status, 401, 'Rating rejected without confirmed address');
};

test 'Invalid ratings are rejected gracefully' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get('/rating/rate/?entity_type=label&entity_id=2&rating=420');
    is ($mech->status, 400, 'Rating > 100 is rejected');

    $mech->get('/rating/rate/?entity_type=label&entity_id=2&rating=-20');
    is ($mech->status, 400, 'Rating < 0 is rejected');

    $mech->get('/rating/rate/?entity_type=label&entity_id=2&rating=asdfg');
    is ($mech->status, 400, 'Non-numeric rating is rejected');
};

1;
