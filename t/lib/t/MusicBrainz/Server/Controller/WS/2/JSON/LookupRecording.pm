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

test 'basic recording lookup, inc=annotation' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

    ws_test_json 'basic recording lookup, inc=annotation',
    '/recording/6e89c516-b0b6-4735-a758-38e31855dcb6?inc=annotation' => encode_json (
        {
            id => "6e89c516-b0b6-4735-a758-38e31855dcb6",
            title => "Plock",
            length => 237133,
            annotation => "this is a recording annotation",
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
                    "release-events" => [{
                        date => "2001-07-04",
                        "area" => {
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso_3166_1_codes" => ["JP"],
                            "iso_3166_2_codes" => [],
                            "iso_3166_3_codes" => []},
                    }],
                    barcode => "4942463511227",
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
                    "release-events" => [{
                        date => "2001-07-04",
                        "area" => {
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso_3166_1_codes" => ["JP"],
                            "iso_3166_2_codes" => [],
                            "iso_3166_3_codes" => []},
                    }],
                    barcode => "4942463511227",
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
                    "release-events" => [{
                        date => "2001-07-04",
                        "area" => {
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso_3166_1_codes" => ["JP"],
                            "iso_3166_2_codes" => [],
                            "iso_3166_3_codes" => []},
                    }],
                    barcode => "4942463511227",
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
                    "release-events" => [{
                        date => "2001-07-04",
                        "area" => {
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso_3166_1_codes" => ["JP"],
                            "iso_3166_2_codes" => [],
                            "iso_3166_3_codes" => []},
                    }],
                    barcode => JSON::null,
                    disambiguation => "",
                    packaging => JSON::null,
                    media => [
                        {
                            format => "CD",
                            position => 1,
                            title => JSON::null,
                            "track-count" => 3,
                            "track-offset" => 0,
                            tracks => [
                                {
                                    id => "4a7c2f1e-cf40-383c-a1c1-d1272d8234cd",
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

test 'recording lookup with release relationships' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with release relationships',
    '/recording/37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9?inc=release-rels' => encode_json (
        {
            id => "37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9",
            title => "Dear Diary",
            disambiguation => "",
            length => 86666,
            relations => [
                {
                    attributes => [],
                    type => 'samples material',
                    'type-id' => '967746f9-9d79-456c-9d1e-50116f0b27fc',
                    direction => 'forward',
                    release => {
                        barcode => '634479663338',
                        country => JSON::null,
                        date => '2007-11-08',
                        "release-events" => [{
                            area => JSON::null,
                            date => '2007-11-08',
                        }],
                        disambiguation => '',
                        id => '4ccb3e54-caab-4ad4-94a6-a598e0e52eec',
                        packaging => JSON::null,
                        quality => 'normal',
                        status => JSON::null,
                        'text-representation' => { language => JSON::null, script => JSON::null },
                        title => 'An Inextricable Tale Audiobook',
                    },
                    begin => '2008',
                    end => JSON::null,
                    ended => JSON::false,
                }
            ]
        });
};

test 'recording lookup with work relationships' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with artists',
    '/recording/0cf3008f-e246-428f-abc1-35f87d584d60?inc=work-rels' => encode_json (
        {
            id => "0cf3008f-e246-428f-abc1-35f87d584d60",
            title => "the Love Bug",
            disambiguation => "",
            length => 242226,
            relations => [
                {
                    attributes => [],
                    direction => 'forward',
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    type => 'performance',
                    'type-id' => 'fdc57134-e05c-30bc-aff6-425684475276',
                    work => {
                        disambiguation => '',
                        id => '46724ef1-241e-3d7f-9f3b-e51ba34e2aa1',
                        iswcs => [],
                        language => JSON::null,
                        title => 'the Love Bug',
                        type => JSON::null,
                    }
                }
            ],
        });
};

1;
