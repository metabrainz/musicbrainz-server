package t::MusicBrainz::Server::Controller::Artist::Aliases;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test aliases
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/aliases', 'get artist aliases');
html_ok($mech->content);
$mech->content_contains('Test Alias', 'has the artist alias');
$mech->content_contains('2000-01-01', 'has alias begin date');
$mech->content_contains('2005-05-06', 'has alias end date');

$mech->get_ok('/artist/60e5d080-c964-11de-8a39-0800200c9a66', 'get artist aliases');
html_ok($mech->content);
$mech->content_unlike(qr/Test Alias/, 'other artist pages do not have the alias');

};

1;
