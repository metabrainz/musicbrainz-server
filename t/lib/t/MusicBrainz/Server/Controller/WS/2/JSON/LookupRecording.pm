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
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7' =>
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            disambiguation => "",
            video => JSON::false,
        };
};

test 'basic recording lookup, inc=annotation' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

    ws_test_json 'basic recording lookup, inc=annotation',
    '/recording/6e89c516-b0b6-4735-a758-38e31855dcb6?inc=annotation' =>
        {
            id => "6e89c516-b0b6-4735-a758-38e31855dcb6",
            title => "Plock",
            length => 237133,
            annotation => "this is a recording annotation",
            disambiguation => "",
            video => JSON::false,
        };
};

test 'recording lookup with releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with releases',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases' =>
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            disambiguation => "",
            video => JSON::false,
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
                            disambiguation => '',
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                        },
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
                            disambiguation => '',
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                        },
                    }],
                    barcode => "4942463511227",
                    disambiguation => "",
                    packaging => JSON::null,
                }]
        };
};

test 'lookup recording with official singles' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'lookup recording with official singles',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases&status=official&type=single' =>
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            disambiguation => "",
            video => JSON::false,
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
                            disambiguation => '',
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                        },
                    }],
                    barcode => "4942463511227",
                    disambiguation => "",
                    packaging => JSON::null,
                }]
        };
};

test 'lookup recording with official singles (+media)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'lookup recording with official singles (+media)',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases+media&status=official&type=single' =>
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            disambiguation => "",
            video => JSON::false,
            releases => [
                {
                    id => "0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e",
                    title => "サマーれげぇ!レインボー",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => {
                        language => 'jpn', script => 'Jpan'
                    },
                    date => "2001-07-04",
                    country => "JP",
                    "release-events" => [{
                        date => "2001-07-04",
                        "area" => {
                            disambiguation => '',
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                        },
                    }],
                    barcode => '4942463511227',
                    disambiguation => "",
                    packaging => JSON::null,
                    media => [
                        {
                            format => "CD",
                            position => 1,
                            title => '',
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
        };
};

test 'recording lookup with artists' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with artists',
    '/recording/0cf3008f-e246-428f-abc1-35f87d584d60?inc=artists' =>
        {
            id => "0cf3008f-e246-428f-abc1-35f87d584d60",
            title => "the Love Bug",
            disambiguation => "",
            length => 243000,
            video => JSON::false,
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
        };
};

test 'recording lookup with puids and isrcs' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with puids and isrcs',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=puids+isrcs' =>
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            disambiguation => "",
            length => 296026,
            video => JSON::false,
            isrcs => [ "JPA600102450" ],
        };
};

test 'recording lookup with release relationships' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with release relationships',
    '/recording/37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9?inc=release-rels' =>
        {
            id => "37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9",
            title => "Dear Diary",
            disambiguation => "",
            length => 86666,
            video => JSON::false,
            relations => [
                {
                    attributes => [],
                    "attribute-values" => {},
                    type => 'samples material',
                    'type-id' => '967746f9-9d79-456c-9d1e-50116f0b27fc',
                    direction => 'forward',
                    release => {
                        barcode => '634479663338',
                        country => 'US',
                        date => '2007-11-08',
                        "release-events" => [{
                            area => {
                              disambiguation => '',
                              id => '489ce91b-6658-3307-9877-795b68554c98',
                              'iso-3166-1-codes' => [
                                'US'
                              ],
                              name => 'United States',
                              'sort-name' => 'United States'
                            },
                            date => '2007-11-08',
                        }],
                        disambiguation => '',
                        id => '4ccb3e54-caab-4ad4-94a6-a598e0e52eec',
                        packaging => JSON::null,
                        quality => 'normal',
                        status => JSON::null,
                        'text-representation' => {
                            language => 'eng',
                            script => 'Latn'
                        },
                        title => 'An Inextricable Tale Audiobook',
                    },
                    begin => '2008',
                    end => JSON::null,
                    ended => JSON::false,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'release',
                }
            ]
        };
};

test 'recording lookup with work relationships' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with artists',
    '/recording/0cf3008f-e246-428f-abc1-35f87d584d60?inc=work-rels' =>
        {
            id => "0cf3008f-e246-428f-abc1-35f87d584d60",
            title => "the Love Bug",
            disambiguation => "",
            length => 243000,
            video => JSON::false,
            relations => [
                {
                    attributes => [],
                    "attribute-values" => {},
                    direction => 'forward',
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    type => 'performance',
                    'type-id' => 'a3005666-a872-32c3-ad06-98af558e99b0',
                    work => {
                        attributes => [],
                        disambiguation => '',
                        id => '46724ef1-241e-3d7f-9f3b-e51ba34e2aa1',
                        iswcs => [],
                        language => JSON::null,
                        title => 'the Love Bug',
                        type => JSON::null,
                    },
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'work',
                }
            ],
        };
};

test 'recording lookup with work-level relationships' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with work-level relationships',
    '/recording/4878bc36-7306-497a-b45a-561d9f7f8573?inc=artist-rels+work-rels+work-level-rels' =>
    {
        disambiguation => '',
        id => '4878bc36-7306-497a-b45a-561d9f7f8573',
        length => 274666,
        video => JSON::false,
        relations => [ {
            attributes => [],
            "attribute-values" => {},
            begin => undef,
            direction => 'forward',
            end => undef,
            ended => JSON::false,
            type => 'performance',
            'type-id' => 'a3005666-a872-32c3-ad06-98af558e99b0',
            work => {
                attributes => [],
                disambiguation => '',
                id => 'f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8',
                iswcs => [],
                language => 'jpn',
                relations => [ {
                    artist => {
                        disambiguation => 'UK dubstep artist Greg Sanders',
                        id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
                        name => 'Distance',
                        'sort-name' => 'Distance'
                    },
                    attributes => [],
                    "attribute-values" => {},
                    begin => undef,
                    direction => 'backward',
                    end => undef,
                    ended => JSON::false,
                    type => 'composer',
                    'type-id' => 'd59d99ea-23d4-4a80-b066-edca32ee158f',
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'artist',
                } ],
                title => 'Asseswaving',
                type => undef
            },
            'source-credit' => '',
            'target-credit' => '',
            'target-type' => 'work',
        } ],
        title => 'Asseswaving'
    };
};

1;
