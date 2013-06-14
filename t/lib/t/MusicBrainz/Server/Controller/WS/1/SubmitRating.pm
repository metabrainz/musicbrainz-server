package t::MusicBrainz::Server::Controller::WS::1::SubmitRating;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
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
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca'), (2, 'other editor', '{CLEARTEXT}password', '63965b645d6c64e41ad695fd80f1f1e9');
EOSQL

subtest 'Submit a single rating' => sub {
    my $request = POST '/ws/1/rating/?type=xml', [
        'entity' => 'artist',
        'id'     => 'a16d1433-ba89-4f72-a47b-a370add0bb55',
        'rating' => '3',
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    ws_test 'check the submission' =>
        '/rating/?type=xml&entity=artist&id=a16d1433-ba89-4f72-a47b-a370add0bb55' =>
        '<?xml version="1.0" encoding="UTF-8"?>
         <metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><user-rating>3</user-rating></metadata>',
        { username => 'editor', password => 'password' };
};

subtest 'Submit a multiple ratings' => sub {
    my $request = POST '/ws/1/rating/?type=xml', [
        'entity.0' => 'artist',
        'id.0'     => 'a16d1433-ba89-4f72-a47b-a370add0bb55',
        'rating.0' => '4',
        'entity.1' => 'label',
        'id.1'     => '6bb73458-6c5f-4c26-8367-66fcef562955',
        'rating.1' => '2',
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    ws_test 'check the submission' =>
        '/rating/?type=xml&entity=artist&id=a16d1433-ba89-4f72-a47b-a370add0bb55' =>
        '<?xml version="1.0" encoding="UTF-8"?>
         <metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><user-rating>4</user-rating></metadata>',
        { username => 'editor', password => 'password' };

    ws_test 'check the submission' =>
        '/rating/?type=xml&entity=label&id=6bb73458-6c5f-4c26-8367-66fcef562955' =>
        '<?xml version="1.0" encoding="UTF-8"?>
         <metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><user-rating>2</user-rating></metadata>',
        { username => 'editor', password => 'password' };
};

};

1;

