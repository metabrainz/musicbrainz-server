package t::MusicBrainz::Server::Controller::Admin::DeleteEditor;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test 'Delete account as a regular user' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $second_session = $test->make_mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'Alice', password => 'secret1' } );

    $second_session->get('/account/edit');
    $second_session->content_contains('You need to be logged in to view this page', 'not logged in in second session');
    $second_session->get('/login');
    $second_session->submit_form( with_fields => { username => 'Alice', password => 'secret1' } );

    $mech->get('/');
    $mech->content_contains('Alice', 'is logged in as regular user');

    $second_session->get('/');
    $second_session->content_contains('Alice', 'is logged in in second session');

    $mech->get('/admin/user/delete/new_editor');
    is($mech->status(), 403, 'cannot delete foreign account');

    $mech->get_ok('/admin/user/delete/Alice', 'can access own deletion page');
    html_ok($mech->content);
    $mech->submit_form( form_id => 'delete-account-form' );

    is($mech->uri->path, '/user/Deleted%20Editor%20%232', q(redirected to the deleted editor's profile));
    $mech->content_contains('Log In', 'no longer logged in');

    $mech->get_ok('/account/edit');
    html_ok($mech->content);
    $mech->content_contains('You need to be logged in to view this page');

    $second_session->get('/');
    is($second_session->status, 500, 'restoring deleted user fails');

    $second_session->get_ok('/');
    $second_session->content_contains('Log In', 'no longer logged in in second session');
};

test 'Delete account as an admin' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        UPDATE editor SET privs = 128 WHERE id = 3; -- make kuno an account admin
        EOSQL

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'kuno', password => 'byld' } );

    $mech->get('/');
    $mech->content_contains('kuno', 'is logged in as admin');

    $mech->get_ok('/admin/user/delete/Alice', 'can access foreign account deletion page');
    html_ok($mech->content);
    $mech->submit_form( form_id => 'delete-account-form' );

    is($mech->uri->path, '/user/Deleted%20Editor%20%232', q(redirected to the deleted editor's profile));
    $mech->content_contains('kuno', 'still logged in');

};

1;
