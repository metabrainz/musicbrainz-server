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

1;
