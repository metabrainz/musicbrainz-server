use utf8;
use strict;
use Test::More;

use HTTP::Request::Common;
use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

use MusicBrainz::WWW::Mechanize;

my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');

subtest 'Submit a single tag' => sub {
    my $request = POST '/ws/1/tag/?type=xml', [
        'entity' => 'artist',
        'id'     => 'a16d1433-ba89-4f72-a47b-a370add0bb55',
        'tags'   => 'musician',
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    ws_test 'check the submission' =>
        '/tag/?type=xml&entity=artist&id=a16d1433-ba89-4f72-a47b-a370add0bb55' =>
        '<?xml version="1.0" encoding="UTF-8"?>
         <metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
          <tag-list><tag>musician</tag></tag-list>
         </metadata>',
        { username => 'editor', password => 'password' };

    done_testing;
};

subtest 'Submit a multiple tags' => sub {
    my $request = POST '/ws/1/tag/?type=xml', [
        'entity.0' => 'artist',
        'id.0'     => '97fa3f6e-557c-4227-bc0e-95a7f9f3285d',
        'tags.0'   => 'magical',
        'entity.1' => 'label',
        'id.1'     => '6bb73458-6c5f-4c26-8367-66fcef562955',
        'tags.1'   => 'production',
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    ws_test 'check the submission' =>
        '/tag/?type=xml&entity=artist&id=97fa3f6e-557c-4227-bc0e-95a7f9f3285d' =>
        '<?xml version="1.0" encoding="UTF-8"?>
         <metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
          <tag-list><tag>magical</tag></tag-list>
         </metadata>',
        { username => 'editor', password => 'password' };

    ws_test 'check the submission' =>
        '/tag/?type=xml&entity=label&id=6bb73458-6c5f-4c26-8367-66fcef562955' =>
        '<?xml version="1.0" encoding="UTF-8"?>
         <metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
          <tag-list><tag>production</tag></tag-list>
         </metadata>',
        { username => 'editor', password => 'password' };

    done_testing;
};

done_testing;

