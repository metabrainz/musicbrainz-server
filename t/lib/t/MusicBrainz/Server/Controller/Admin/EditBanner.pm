package t::MusicBrainz::Server::Controller::Admin::EditBanner;

use Test::Routine;

with 't::Mechanize', 't::Context';

test 'Setting a banner message' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/login');
    $mech->submit_form(with_fields => { username => 'new_editor', password => 'password' });

    $mech->get('/admin/banner/edit');
    $mech->submit_form(with_fields => { 'banner.message' => 'hey everybody!!' });

    $mech->get('/');
    $mech->content_contains('hey everybody!!', 'homepage contains banner message');

    $mech->get('/admin/banner/edit');
    $mech->submit_form(with_fields => { 'banner.message' => '' });
};

1;
