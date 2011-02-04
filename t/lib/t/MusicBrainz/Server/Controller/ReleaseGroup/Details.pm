package t::MusicBrainz::Server::Controller::ReleaseGroup::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

$mech->get_ok("/release-group/234c079d-374e-4436-9448-da92dedef3ce/details",
              'fetch release group details page');
xml_ok($mech->content);
$mech->content_contains('http://musicbrainz.org/release-group/234c079d-374e-4436-9448-da92dedef3ce',
                        '..has permanent link');
$mech->content_contains('<td>234c079d-374e-4436-9448-da92dedef3ce</td>',
                        '..has mbid in plain text');

};

1;
