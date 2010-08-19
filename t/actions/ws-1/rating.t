use utf8;
use strict;
use Test::More;

use HTTP::Request::Common;
use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

use MusicBrainz::WWW::Mechanize;

my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');

subtest 'Submit a single rating' => sub {
    my $request = POST '/ws/1/rating/?type=xml', [
        'entity' => 'artist',
        'id'     => 'a16d1433-ba89-4f72-a47b-a370add0bb55',
        'rating' => '3',
    ];

    $mech->credentials('localhost:80', 'webservice', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    ws_test 'check the submission' =>
        '/rating/?type=xml&entity=artist&id=a16d1433-ba89-4f72-a47b-a370add0bb55' =>
        '<?xml version="1.0" encoding="UTF-8"?>
         <metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><user-rating>3</user-rating></metadata>',
        { username => 'editor', password => 'password' };

    done_testing;
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

    $mech->credentials('localhost:80', 'webservice', 'editor', 'password');

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

    done_testing;
};

done_testing;

