package t::MusicBrainz::Server::Controller::User::Donation;
use Test::Routine;
use Test::More;

use LWP;
use LWP::UserAgent::Mockable;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get('/account/donation');
$mech->content_contains('You will never be nagged');

$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'kuno', password => 'byld' } );

$mech->get('/account/donation');
$mech->content_contains('We have not received a donation from you recently');

};

1;
