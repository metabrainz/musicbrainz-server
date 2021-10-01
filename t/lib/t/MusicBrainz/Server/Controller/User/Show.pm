package t::MusicBrainz::Server::Controller::User::Show;
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get('/user/new_editor');
$mech->content_contains('Collection', 'Collection tab appears on profile of user');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'alice', password => 'secret1' } );

$mech->get('/user/alice');
$mech->content_contains('Collection', 'Collection tab appears on own profile, even if marked private');

};

1;
