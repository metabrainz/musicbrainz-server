package t::MusicBrainz::Server::Controller::User::Login;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get_ok('/login');
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
