package t::MusicBrainz::Server::Controller::Recording::Details;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

$mech->get_ok("/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/details",
              'fetch recording details page');
xml_ok($mech->content);
$mech->content_contains('http://musicbrainz.org/recording/54b9d183-7dab-42ba-94a3-7388a66604b8',
                        '..has permanent link');
$mech->content_contains('<td>54b9d183-7dab-42ba-94a3-7388a66604b8</td>',
                        '..has mbid in plain text');

};

1;
