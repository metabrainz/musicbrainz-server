package t::MusicBrainz::Server::Controller::Release::Details;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

$mech->get_ok("/release/f205627f-b70a-409d-adbe-66289b614e80/details",
              'fetch release details page');
xml_ok($mech->content);
$mech->content_contains('http://musicbrainz.org/release/f205627f-b70a-409d-adbe-66289b614e80',
                        '..has permanent link');
$mech->content_contains('<td>f205627f-b70a-409d-adbe-66289b614e80</td>',
                        '..has mbid in plain text');

};

1;
