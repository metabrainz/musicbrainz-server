package t::MusicBrainz::Server::Controller::Label::Details;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_cdtoc');

$mech->get_ok("/label/46f0f4cd-8aab-4b33-b698-f459faf64190/details",
              'fetch label details page');
html_ok($mech->content);

$mech->content_contains('http://musicbrainz.org/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
                        '..has permanent link');
$mech->content_contains('<td>46f0f4cd-8aab-4b33-b698-f459faf64190</td>',
                        '..has mbid in plain text');

};

1;
