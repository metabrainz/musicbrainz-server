package t::MusicBrainz::Server::Controller::User::Login;
use Test::Routine;
use Test::More;
use Hook::LexWrap;
use MusicBrainz::Server::Test qw( html_ok );
use DBDefs;

with 't::Mechanize', 't::Context';

wrap test, pre => sub { *DBDefs::SSL_REDIRECTS_ENABLED = sub { 1 }; };

test all => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('https://localhost/login');
    html_ok($mech->content);
    $mech->submit_form( with_fields => { username => '', password => '' } );
    $mech->content_contains('Incorrect username or password');
    $mech->submit_form( with_fields => { username => 'new_editor', password => '' } );
    $mech->content_contains('Incorrect username or password');
    $mech->submit_form( with_fields => { username => '', password => 'password' } );
    $mech->content_contains('Incorrect username or password');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
    is($mech->uri->path, '/user/new_editor');

};

test 'https login' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('https://localhost/login');
    html_ok($mech->content);
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
    is($mech->uri->path, '/user/new_editor');
    is($mech->uri->scheme, 'https', 'We started secure, should still be secure');
};

test 'http login with redirects to ssl' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('http://localhost/login');
    html_ok($mech->content);
    is($mech->uri->scheme, 'https', 'Redirected to secure login form');
    use Data::Dumper;
    warn $mech->cookie_jar->as_string."\n";
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
    is($mech->uri->path, '/user/new_editor');
    is($mech->uri->scheme, 'http', 'We started insecure, so correctly redirected back to http');
};

test 'Can login with usernames that contain the "/" character"' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password) VALUES (100, 'ocharles/bot', 'mb');
EOSQL

    $mech->get_ok('/user/ocharles%2Fbot');
    html_ok($mech->content);
    $mech->content_contains('ocharles/bot');
    $mech->follow_link_ok({ url_regex => qr{/login} });
    $mech->submit_form(
        with_fields => { username => 'ocharles/bot', password => 'mb' }
    );
    like($mech->uri->path, qr{/user/ocharles%2Fbot});
};

1;
