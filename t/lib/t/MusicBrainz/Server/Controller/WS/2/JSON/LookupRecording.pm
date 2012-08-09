package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupRecording;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic recording lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic recording lookup',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7' => encode_json (
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            disambiguation => JSON::null,
        });

};

test 'recording lookup with artists' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with artists',
    '/recording/0cf3008f-e246-428f-abc1-35f87d584d60?inc=artists' => encode_json (
        {
            id => "0cf3008f-e246-428f-abc1-35f87d584d60",
            title => "the Love Bug",
            disambiguation => JSON::null,
            length => 242226,
            "artist-credit" => [
                {
                    name => "m-flo",
                    artist => {
                        id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                        name => "m-flo",
                        "sort-name" => "m-flo",
                        disambiguation => JSON::null,
                    },
                    joinphrase => "♥",
                },
                {
                    name => "BoA",
                    artist => {
                        id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
                        name => "BoA",
                        "sort-name" => "BoA",
                        disambiguation => JSON::null,
                    },
                    joinphrase => "",
                }
                ],
        });
};

test 'recording lookup with puids and isrcs' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with puids and isrcs',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=puids+isrcs' => encode_json (
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            disambiguation => JSON::null,
            length => 296026,
            puids => [ "cdec3fe2-0473-073c-3cbb-bfb0c01a87ff" ],
            isrcs => [ "JPA600102450" ],
        });
};

1;

