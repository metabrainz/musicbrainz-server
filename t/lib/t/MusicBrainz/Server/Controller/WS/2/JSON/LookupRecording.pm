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
            disambiguation => "",
        });

};

test 'recording lookup with releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with releases',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases' => encode_json (
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            disambiguation => "",
            releases => [
                {
                    id => "0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e",
                    title => "サマーれげぇ!レインボー",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Jpan" },
                    date => "2001-07-04",
                    country => "JP",
                    barcode => "4942463511227",
                    asin => JSON::null,
                    disambiguation => "",
                    packaging => JSON::null,
                },
                {
                    id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
                    title => "Summer Reggae! Rainbow",
                    status => "Pseudo-Release",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Latn" },
                    date => "2001-07-04",
                    country => "JP",
                    barcode => "4942463511227",
                    asin => JSON::null,
                    disambiguation => "",
                    packaging => JSON::null,
                }]
        });
};


test 'lookup recording with official singles' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'lookup recording with official singles',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases&status=official&type=single' => encode_json (
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            disambiguation => "",
            releases => [
                {
                    id => "0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e",
                    title => "サマーれげぇ!レインボー",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Jpan" },
                    date => "2001-07-04",
                    country => "JP",
                    barcode => "4942463511227",
                    asin => JSON::null,
                    disambiguation => "",
                    packaging => JSON::null,
                }]
        });
};

test 'lookup recording with official singles (+media)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'lookup recording with official singles (+media)',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases+media&status=official&type=single' => encode_json (
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            disambiguation => "",
            releases => [
                {
                    id => "0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e",
                    title => "サマーれげぇ!レインボー",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => {
                        language => JSON::null, script => JSON::null
                    },
                    date => "2001-07-04",
                    country => "JP",
                    barcode => JSON::null,
                    asin => JSON::null,
                    disambiguation => "",
                    packaging => JSON::null,
                    media => [
                        {
                            format => "CD",
                            title => JSON::null,
                            "track-count" => 3,
                            "track-offset" => 0,
                            tracks => [
                                {
                                    number => "1",
                                    title => "サマーれげぇ!レインボー",
                                    length => 296026,
                                }
                            ]
                        }]
                }]
        });

};

test 'recording lookup with artists' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with artists',
    '/recording/0cf3008f-e246-428f-abc1-35f87d584d60?inc=artists' => encode_json (
        {
            id => "0cf3008f-e246-428f-abc1-35f87d584d60",
            title => "the Love Bug",
            disambiguation => "",
            length => 242226,
            "artist-credit" => [
                {
                    name => "m-flo",
                    artist => {
                        id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                        name => "m-flo",
                        "sort-name" => "m-flo",
                        disambiguation => "",
                    },
                    joinphrase => "♥",
                },
                {
                    name => "BoA",
                    artist => {
                        id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
                        name => "BoA",
                        "sort-name" => "BoA",
                        disambiguation => "",
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
            disambiguation => "",
            length => 296026,
            puids => [ "cdec3fe2-0473-073c-3cbb-bfb0c01a87ff" ],
            isrcs => [ "JPA600102450" ],
        });
};

1;

