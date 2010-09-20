use utf8;
use strict;
use Test::More;

use HTTP::Request::Common;
use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

use MusicBrainz::WWW::Mechanize;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');

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
ok($mech->success, 'was not sucessful: ' . $response->content);

my $cdstub = $c->model('CDStub')->get_by_discid('ML1kzVX3aeK0.LBLzp4IXfkGd5I-');
ok(defined $cdstub);

done_testing;
