package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupArtist;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'errors' => sub {

    use Test::JSON import => [ 'is_valid_json', 'is_json' ];

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;
    $mech->default_header ("Accept" => "application/json");
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=coffee');
    is ($mech->status, 400);

    is_valid_json ($mech->content);
    is_json ($mech->content, encode_json ({
        error => "coffee is not a valid inc parameter for the artist resource."
    }));

    $mech->get('/ws/2/artist/00000000-1111-2222-3333-444444444444');
    is ($mech->status, 404);
    is_valid_json ($mech->content);
    is_json ($mech->content, encode_json ({ error => "Not Found" }));
};

test 'basic artist lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic artist lookup',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a' => encode_json (
        {
            id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
            name => "Distance",
            "sort-name" => "Distance",
            type => "Person",
            disambiguation => "UK dubstep artist Greg Sanders",
            country => JSON::null,
        });
};

test 'basic artist lookup, inc=aliases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic artist lookup, inc=aliases',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=aliases' => encode_json (
        {
            id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
            name => "BoA",
            "sort-name" => "BoA",
            country => JSON::null,
            disambiguation => "",
            type => "Person",
            "life-span" => { "begin" => "1986-11-05", "ended" => JSON::false },
            aliases => [
                { name => "Beat of Angel", "sort-name" => "Beat of Angel" },
                { name => "BoA Kwon", "sort-name" => "BoA Kwon" },
                { name => "Kwon BoA", "sort-name" => "Kwon BoA" },
                { name => "ボア", "sort-name" => "ボア" },
                { name => "보아", "sort-name" => "보아" },
                ],
        });

};

test 'artist lookup with releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with releases',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases' => encode_json (
        {
            id => "802673f0-9b88-4e8a-bb5c-dd01d68b086f",
            name => "7人祭",
            "sort-name" => "7nin Matsuri",
            country => JSON::null,
            disambiguation => "",
            type => "Group",
            releases => [
                {
                    id => "0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e",
                    title => "サマーれげぇ!レインボー",
                    disambiguation => "",
                    packaging => JSON::null,
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Jpan" },
                    date => "2001-07-04",
                    country => "JP",
                    barcode => "4942463511227",
                    asin => JSON::null,
                },
                {
                    id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
                    title => "Summer Reggae! Rainbow",
                    disambiguation => "",
                    packaging => JSON::null,
                    status => "Pseudo-Release",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Latn" },
                    date => "2001-07-04",
                    country => "JP",
                    barcode => "4942463511227",
                    asin => JSON::null,
                }
                ],
        });
};

test 'artist lookup with pseudo-releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with pseudo-releases',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases&type=single&status=pseudo-release' => encode_json (
        {
            id => "802673f0-9b88-4e8a-bb5c-dd01d68b086f",
            name => "7人祭",
            "sort-name" => "7nin Matsuri",
            country => JSON::null,
            disambiguation => "",
            type => "Group",
            releases => [
                {
                    id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
                    title => "Summer Reggae! Rainbow",
                    disambiguation => "",
                    packaging => JSON::null,
                    status => "Pseudo-Release",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Latn" },
                    date => "2001-07-04",
                    country => "JP",
                    barcode => "4942463511227",
                    asin => JSON::null,
                }
                ],
        });
};


test 'artist lookup with releases and discids' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with releases and discids',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=releases+discids' => encode_json(
        {
            id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
            name => "Distance",
            "sort-name" => "Distance",
            country => JSON::null,
            disambiguation => "UK dubstep artist Greg Sanders",
            type => "Person",
            releases => [
                {
                    id => "3b3d130a-87a8-4a47-b9fb-920f2530d134",
                    title => "Repercussions",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    date => "2008-11-17",
                    disambiguation => "",
                    packaging => JSON::null,
                    country => "GB",
                    asin => JSON::null,
                    barcode => "600116822123",
                    media => [
                        {
                            title => JSON::null,
                            format => "CD",
                            discids => [ { id => "93K4ogyxWlv522XF0BG8fZOuay4-", sectors => 215137 } ],
                            "track-count" => 9,
                        },
                        {
                            title => "Chestplate Singles",
                            format => "CD",
                            discids => [ { id => "VnL0A7ksXznBxvZ94H3Z61EZY3k-", sectors => 208393 } ],
                            "track-count" => 9,
                        }]
                },
                {
                    id => "adcf7b48-086e-48ee-b420-1001f88d672f",
                    title => "My Demons",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    date => "2007-01-29",
                    disambiguation => "",
                    packaging => JSON::null,
                    country => "GB",
                    asin => JSON::null,
                    barcode => "600116817020",
                    media => [
                        {
                            title => JSON::null,
                            format => "CD",
                            discids => [ { id => "75S7Yp3IiqPVREQhjAjMXPhwz0Y-", sectors => 281289 } ],
                            "track-count" => 12,
                        }]
                }]
        });
};

test 'artist lookup with recordings and artist credits' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with recordings and artist credits',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=recordings+artist-credits' => encode_json (
        {
            id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
            name => "m-flo",
            "sort-name" => "m-flo",
            type => "Group",
            country => JSON::null,
            disambiguation => "",
            "life-span" => { "begin" => "1998", "ended" => JSON::false },
            "recordings" => [
                {
                    id => "0cf3008f-e246-428f-abc1-35f87d584d60",
                    title => "the Love Bug",
                    length => 242226,
                    disambiguation => "",
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
                            joinphrase => ""
                        }
                    ]
                },
                {
                    id => "84c98ebf-5d40-4a29-b7b2-0e9c26d9061d",
                    title => "the Love Bug (Big Bug NYC remix)",
                    length => 222000,
                    disambiguation => "",
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
                            joinphrase => ""
                        }
                    ]
                },
            ]
        });
};

test 'artist lookup with release groups' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with release groups',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=release-groups&type=single' => encode_json (
        {
            id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
            name => "m-flo",
            "sort-name" => "m-flo",
            type => "Group",
            country => JSON::null,
            disambiguation => "",
            "life-span" => { "begin" => "1998", "ended" => JSON::false },
            "release-groups" => [
                {
                    id => "153f0a09-fead-3370-9b17-379ebd09446b",
                    title => "the Love Bug",
                    disambiguation => "",
                    "first-release-date" => "2004-03-17",
                    "primary-type" => "Single",
                    "secondary-types" => [],
                }
            ]
        });
};

test 'single artist release lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'single artist release lookup',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=releases' => encode_json (
        {
            id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
            name => "m-flo",
            "sort-name" => "m-flo",
            type => "Group",
            country => JSON::null,
            disambiguation => "",
            "life-span" => { "begin" => "1998", "ended" => JSON::false },
            releases => [
                {
                    id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
                    title => "the Love Bug",
                    date => "2004-03-17",
                    "text-representation" => { "language" => "eng", "script" => "Latn" },
                    country => "JP",
                    disambiguation => "",
                    packaging => JSON::null,
                    quality => "normal",
                    status => "Official",
                    barcode => "4988064451180",
                    asin => JSON::null,
                }
            ]
        });
};

test 'various artists release lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'various artists release lookup',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=releases+various-artists&status=official' => encode_json (
        {
            id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
            name => "BoA",
            "sort-name" => "BoA",
            "life-span" => { "begin" => "1986-11-05", "ended" => JSON::false },
            country => JSON::null,
            disambiguation => "",
            type => "Person",
            releases => [
                {
                    id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
                    title => "the Love Bug",
                    packaging => JSON::null,
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { "language" => "eng", "script" => "Latn" },
                    date => "2004-03-17",
                    country => "JP",
                    barcode => "4988064451180",
                    asin => JSON::null,
                    disambiguation => "",
                }
            ]
        });
};

test 'artist lookup with works (using l_artist_work)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with works (using l_artist_work)',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=works' => encode_json (
        {
            id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
            name => "Distance",
            "sort-name" => "Distance",
            type => "Person",
            disambiguation => "UK dubstep artist Greg Sanders",
            country => JSON::null,
            works => [
                {
                    id => "f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8",
                    title => "Asseswaving",
                    iswcs => [],
                }
            ]
        });
};

test 'artist lookup with works (using l_recording_work)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with works (using l_recording_work)',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=works' => encode_json (
        {
            id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
            name => "BoA",
            "sort-name" => "BoA",
            country => JSON::null,
            disambiguation => "",
            type => "Person",
            "life-span" => { "begin" => "1986-11-05", "ended" => JSON::false },
            works => [
                {
                    id => "286ecfdd-2ffe-3bc7-b3e9-04cc8cea229b",
                    title => "Easy To Be Hard",
                    iswcs => [],
                },
                {
                    id => "2d967c29-63dc-309d-bbc1-a2d38639aaa1",
                    title => "心の手紙",
                    iswcs => [],
                },
                {
                    id => "303f9bd2-152f-3145-9e09-afa34edb6a57",
                    title => "DOUBLE",
                    iswcs => [],
                },
                {
                    id => "46724ef1-241e-3d7f-9f3b-e51ba34e2aa1",
                    title => "the Love Bug",
                    iswcs => [],
                },
                {
                    id => "4b6a46c2-a904-3471-9bff-3942d4549f47",
                    title => "SOME DAY ONE DAY )",
                    iswcs => [],
                },
                {
                    id => "50c07b24-7ee2-31ac-ab87-f0d399011c71",
                    title => "Milky Way 〜君の歌〜",
                    iswcs => [],
                },
                {
                    id => "511f5124-c0ae-3386-bb76-4b6521498a68",
                    title => "Milky Way-君の歌-",
                    iswcs => [],
                },
                {
                    id => "53d1fbac-e60a-38cb-85ff-e5a9224c9749",
                    title => "Be the one",
                    iswcs => [],
                },
                {
                    id => "61ab56f0-e803-3aef-a91b-63564b7a8043",
                    title => "Rock With You",
                    iswcs => [],
                },
                {
                    id => "6f08d5a8-1811-3e5e-848b-35ffa77babe5",
                    title => "Midnight Parade",
                    iswcs => [],
                },
                {
                    id => "7981d409-8e76-33df-be27-ef625d81c501",
                    title => "Shine We Are!",
                    iswcs => [],
                },
                {
                    id => "7e78f281-52b4-315b-9d7b-6d215732f3d7",
                    title => "EXPECT",
                    iswcs => [],
                },
                {
                    id => "cd86f9e2-83ce-3192-a817-fe6c98079303",
                    title => "Song With No Name～名前のない歌～",
                    iswcs => [],
                },
                {
                    id => "d2f1ea1f-de2e-3d0c-b534-e96377912478",
                    title => "OVER～across the time～",
                    iswcs => [],
                },
                {
                    id => "f23ae726-0300-3830-b1ca-634f4362f78c",
                    title => "LOVE & HONESTY",
                    iswcs => [],
                }]
        });
};

1;

