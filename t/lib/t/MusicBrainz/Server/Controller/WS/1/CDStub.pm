package t::MusicBrainz::Server::Controller::WS::1::CDStub;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use HTTP::Request::Common;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 1
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

my $request = POST '/ws/1/release/?type=xml&client=test-1.0', [
    toc => '1 2 18288 150 11599',
    discid => 'ML1kzVX3aeK0.LBLzp4IXfkGd5I-',
    title => 'The Drive',
    artist => 'Pixel',
    track0 => 'Track 1',
    artist0 => 'Artist 1',
    track1 => 'Track 2',
    artist1 => 'Artist 2'
];

$mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

my $response = $mech->request($request);
ok($mech->success, 'was sucessful in submitting cd stub');

my $cdstub = $c->model('CDStub')->get_by_discid('ML1kzVX3aeK0.LBLzp4IXfkGd5I-');
ok(defined $cdstub);

$request = POST '/ws/1/release/?type=xml&client=test-1.0', [
    toc => '1 3 18288 11599',
    discid => 'ML1kzVX3aeK0.LBLzp4IXfkGd5I-',
    artist => 'Pixel',
    track0 => 'Track 1',
    artist0 => 'Artist 1',
    track1 => 'Track 2',
    artist1 => 'Artist 2'
];

$mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

$response = $mech->request($request);
ok(!$mech->success, 'cant submit invalid cd stub data');

};

1;

