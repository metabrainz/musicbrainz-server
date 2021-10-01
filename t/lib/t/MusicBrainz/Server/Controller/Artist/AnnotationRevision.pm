package t::MusicBrainz::Server::Controller::Artist::AnnotationRevision;
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/annotation/1', 'Fetch an annotation page');
$mech->content_contains('Test annotation 1', '..has annotation');
$mech->content_contains('More annotation', '..has annotation');

};

1;
