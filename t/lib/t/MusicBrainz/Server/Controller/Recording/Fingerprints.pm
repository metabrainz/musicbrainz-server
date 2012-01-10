package t::MusicBrainz::Server::Controller::Recording::Fingerprints;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce/fingerprints', 'get recording fingerprints');
# html_ok is trying to parse <script> contents as HTML
#html_ok($mech->content);
$mech->content_contains('puid/b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', 'has puid 1');
$mech->content_contains('puid/134478d1-306e-41a1-8b37-ff525e53c8be', 'has puid 2');

$mech->get_ok('/recording/659f405b-b4ee-4033-868a-0daa27784b89/fingerprints', 'get a page with no puids');
$mech->content_contains('This recording does not have any associated PUIDs');

};

1;
