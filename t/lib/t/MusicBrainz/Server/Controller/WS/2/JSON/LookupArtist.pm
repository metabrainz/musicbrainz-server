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

    use Test::JSON import => [ 'is_json' ];

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;
    $mech->default_header("Accept" => "application/json");
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=coffee');
    is($mech->status, 400);

    is_json($mech->content, encode_json({
        error => "coffee is not a valid inc parameter for the artist resource.",
        help => 'For usage, please see: https://musicbrainz.org/development/mmd',
    }));

    $mech->get('/ws/2/artist/00000000-1111-2222-3333-444444444444');
    is($mech->status, 404);
    is_json($mech->content, encode_json({
          error => "Not Found",
          help => 'For usage, please see: https://musicbrainz.org/development/mmd',
    }));
};

test 'basic artist lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic artist lookup',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a' =>
        {
            id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
            name => "Distance",
            "sort-name" => "Distance",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "UK dubstep artist Greg Sanders",
            "life-span" => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'basic artist lookup, inc=annotation' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

    ws_test_json 'basic artist lookup, inc=annotation',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=annotation' =>
        {
            id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
            name => "Distance",
            "sort-name" => "Distance",
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            annotation => "this is an artist annotation",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "UK dubstep artist Greg Sanders",
            "life-span" => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false,
            },
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'basic artist lookup, inc=aliases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic artist lookup, inc=aliases',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=aliases' =>
        {
            id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
            name => "BoA",
            "sort-name" => "BoA",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => "1986-11-05",
                end => JSON::null,
                ended => JSON::false
            },
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            aliases => [
                { name => "Beat of Angel", "sort-name" => "Beat of Angel", locale => JSON::null, primary => JSON::null, type => JSON::null, "type-id" => JSON::null, begin => JSON::null, end => JSON::null, ended => JSON::false },
                { name => "BoA Kwon", "sort-name" => "BoA Kwon", locale => JSON::null, primary => JSON::null, type => JSON::null, "type-id" => JSON::null, begin => JSON::null, end => JSON::null, ended => JSON::false },
                { name => "Kwon BoA", "sort-name" => "Kwon BoA", locale => JSON::null, primary => JSON::null, type => JSON::null, "type-id" => JSON::null, begin => JSON::null, end => JSON::null, ended => JSON::false },
                { name => "ボア", "sort-name" => "ボア", locale => JSON::null, primary => JSON::null, type => JSON::null, "type-id" => JSON::null, begin => JSON::null, end => JSON::null, ended => JSON::false },
                { name => "보아", "sort-name" => "보아", locale => JSON::null, primary => JSON::null, type => JSON::null, "type-id" => JSON::null, begin => JSON::null, end => JSON::null, ended => JSON::false },
                ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'basic artist lookup, inc=url-rels' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic artist lookup, inc=url-rels',
    '/artist/05d83760-08b5-42bb-a8d7-00d80b3bf47c?inc=url-rels' =>
        {
            id => "05d83760-08b5-42bb-a8d7-00d80b3bf47c",
            name => "Paul Allgood",
            "sort-name" => "Allgood, Paul",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            relations => [
                {
                    attributes => [],
                    "attribute-ids" => {},
                    "attribute-values" => {},
                    direction => "forward",
                    url => {
                        id => '37ad368b-d37d-46d4-be3a-349f78355253',
                        resource => 'https://www.imdb.com/name/nm4057169/'
                    },
                    type => "IMDb",
                    'type-id' => '94c8b0cc-4477-4106-932c-da60e63de61c',
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'url',
                },
                {
                    attributes => [],
                    "attribute-ids" => {},
                    "attribute-values" => {},
                    direction => "forward",
                    url => {
                        id => 'daa73242-f491-4d94-bbd0-b08a03a4a69b',
                        resource => 'http://www.paulallgood.com/'
                    },
                    type => "blog",
                    'type-id' => 'eb535226-f8ca-499d-9b18-6a144df4ae6f',
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'url',
                },
                {
                    attributes => [],
                    "attribute-ids" => {},
                    "attribute-values" => {},
                    direction => "forward",
                    url => {
                        id => 'e0a79771-e9f0-4127-b58a-f5e6869c8e96',
                        resource => 'http://www.discogs.com/artist/Paul+Allgood'
                    },
                    type => "discogs",
                    'type-id' => '04a5b104-a4c2-4bac-99a1-7b837c37d9e4',
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'url',
                },
                {
                    attributes => [],
                    "attribute-ids" => {},
                    "attribute-values" => {},
                    direction => "forward",
                    url => {
                        id => '6f0fce21-abd4-4ef7-a7cf-d9ec9830b350',
                        resource => 'http://farm4.static.flickr.com/3652/3334818186_6e19173c33_b.jpg'
                    },
                    type => "image",
                    "type-id" => '221132e9-e30e-43f2-a741-15afc4c5fa7c',
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'url',
                },
                {
                    attributes => [],
                    "attribute-ids" => {},
                    "attribute-values" => {},
                    direction => "forward",
                    url => {
                        id => '09ea2bb6-0280-4be1-aa7a-46e641c16451',
                        resource => 'http://members.boardhost.com/wedlock/'
                    },
                    type => "online community",
                    'type-id' => '35b3a50f-bf0e-4309-a3b4-58eeed8cee6a',
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'url',
                },
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'artist lookup with releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with releases',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases' =>
        {
            id => "802673f0-9b88-4e8a-bb5c-dd01d68b086f",
            name => "7人祭",
            "sort-name" => "7nin Matsuri",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Group",
            "type-id" => "e431f5f6-b5d2-343d-8b36-72607fffb74b",
            releases => [
                {
                    id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
                    title => "Summer Reggae! Rainbow",
                    disambiguation => "",
                    packaging => JSON::null,
                    "packaging-id" => JSON::null,
                    status => "Pseudo-Release",
                    "status-id" => "41121bb9-3413-3818-8a9a-9742318349aa",
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
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4942463511227",
                },
                {
                    id => "0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e",
                    title => "サマーれげぇ!レインボー",
                    disambiguation => "",
                    packaging => JSON::null,
                    "packaging-id" => JSON::null,
                    status => "Official",
                    "status-id" => "4e304316-386d-3409-af2e-78857eec5cfe",
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
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4942463511227",
                },
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'artist lookup with pseudo-releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with pseudo-releases',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases&type=single&status=pseudo-release' =>
        {
            id => "802673f0-9b88-4e8a-bb5c-dd01d68b086f",
            name => "7人祭",
            "sort-name" => "7nin Matsuri",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Group",
            "type-id" => "e431f5f6-b5d2-343d-8b36-72607fffb74b",
            releases => [
                {
                    id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
                    title => "Summer Reggae! Rainbow",
                    disambiguation => "",
                    packaging => JSON::null,
                    "packaging-id" => JSON::null,
                    status => "Pseudo-Release",
                    "status-id" => "41121bb9-3413-3818-8a9a-9742318349aa",
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
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4942463511227",
                }
                ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};


test 'artist lookup with releases and discids' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with releases and discids',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=releases+discids' =>
        {
            id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
            name => "Distance",
            "sort-name" => "Distance",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "UK dubstep artist Greg Sanders",
            "life-span" => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            releases => [
                {
                    id => "adcf7b48-086e-48ee-b420-1001f88d672f",
                    title => "My Demons",
                    status => "Official",
                    "status-id" => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    date => "2007-01-29",
                    disambiguation => "",
                    packaging => JSON::null,
                    "packaging-id" => JSON::null,
                    country => "GB",
                    barcode => "600116817020",
                    media => [
                        {
                            title => '',
                            format => "CD",
                            "format-id" => "9712d52a-4509-3d4b-a1a2-67c88c643e31",
                            position => 1,
                            discs => [
                                {
                                    id => "75S7Yp3IiqPVREQhjAjMXPhwz0Y-",
                                    'offset-count' => 12,
                                    offsets => [
                                        150,
                                        27852,
                                        49751,
                                        75876,
                                        99845,
                                        120876,
                                        140765,
                                        165856,
                                        188422,
                                        211757,
                                        232229,
                                        255810
                                    ],
                                    sectors => 281289
                                }
                            ],
                            "track-count" => 12,
                        }],
                    "release-events" => [{
                        date => "2007-01-29",
                        "area" => {
                            disambiguation => '',
                            "id" => "8a754a16-0027-3a29-b6d7-2b40ea0481ed",
                            "name" => "United Kingdom",
                            "sort-name" => "United Kingdom",
                            "iso-3166-1-codes" => ["GB"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                },
                {
                    id => "3b3d130a-87a8-4a47-b9fb-920f2530d134",
                    title => "Repercussions",
                    status => "Official",
                    "status-id" => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    date => "2008-11-17",
                    disambiguation => "",
                    packaging => JSON::null,
                    "packaging-id" => JSON::null,
                    country => "GB",
                    barcode => "600116822123",
                    media => [
                        {
                            title => '',
                            format => "CD",
                            "format-id" => "9712d52a-4509-3d4b-a1a2-67c88c643e31",
                            position => 1,
                            discs => [
                                {
                                    id => "93K4ogyxWlv522XF0BG8fZOuay4-",
                                    'offset-count' => 9,
                                    offsets => [
                                        150,
                                        23303,
                                        48850,
                                        73305,
                                        98815,
                                        125348,
                                        147548,
                                        172225,
                                        194409
                                    ],
                                    sectors => 215137
                                }
                            ],
                            "track-count" => 9,
                        },
                        {
                            title => "Chestplate Singles",
                            format => "CD",
                            "format-id" => "9712d52a-4509-3d4b-a1a2-67c88c643e31",
                            position => 2,
                            discs => [
                                {
                                    id => "VnL0A7ksXznBxvZ94H3Z61EZY3k-",
                                    'offset-count' => 9,
                                    offsets => [
                                        150,
                                        26801,
                                        42538,
                                        64421,
                                        90680,
                                        114510,
                                        138939,
                                        164009,
                                        186929
                                    ],
                                    sectors => 208393
                                }
                            ],
                            "track-count" => 9,
                        }],
                    "release-events" => [{
                        date => "2008-11-17",
                        "area" => {
                            disambiguation => '',
                            "id" => "8a754a16-0027-3a29-b6d7-2b40ea0481ed",
                            "name" => "United Kingdom",
                            "sort-name" => "United Kingdom",
                            "iso-3166-1-codes" => ["GB"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }]
                },
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'artist lookup with recordings and artist credits' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with recordings and artist credits',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=recordings+artist-credits' =>
        {
            id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
            name => "m-flo",
            "sort-name" => "m-flo",
            type => "Group",
            "type-id" => "e431f5f6-b5d2-343d-8b36-72607fffb74b",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => "1998",
                end => JSON::null,
                ended => JSON::false,
            },
            "recordings" => [
                {
                    id => "0cf3008f-e246-428f-abc1-35f87d584d60",
                    title => "the Love Bug",
                    length => 243000,
                    disambiguation => "",
                    "artist-credit" => [
                        {
                            name => "m-flo",
                            artist => {
                                id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                                name => "m-flo",
                                "sort-name" => "m-flo",
                                disambiguation => "",
                                type => "Group",
                                "type-id" => "e431f5f6-b5d2-343d-8b36-72607fffb74b",
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
                                "type" => "Person",
                                "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
                            },
                            joinphrase => ""
                        }
                    ],
                    video => JSON::false,
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
                                type => "Group",
                                "type-id" => "e431f5f6-b5d2-343d-8b36-72607fffb74b",
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
                                "type" => "Person",
                                "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
                            },
                            joinphrase => ""
                        }
                    ],
                    video => JSON::false,
                },
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'artist lookup with release groups' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with release groups',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=release-groups&type=single' =>
        {
            id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
            name => "m-flo",
            "sort-name" => "m-flo",
            type => "Group",
            "type-id" => "e431f5f6-b5d2-343d-8b36-72607fffb74b",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => "1998",
                end => JSON::null,
                ended => JSON::false,
            },
            "release-groups" => [
                {
                    id => "153f0a09-fead-3370-9b17-379ebd09446b",
                    title => "the Love Bug",
                    disambiguation => "",
                    "first-release-date" => "2004-03-17",
                    "primary-type" => "Single",
                    "primary-type-id" => "d6038452-8ee0-3f68-affc-2de9a1ede0b9",
                    "secondary-types" => [],
                    "secondary-type-ids" => [],
                }
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'single artist release lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'single artist release lookup',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=releases' =>
        {
            id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
            name => "m-flo",
            "sort-name" => "m-flo",
            type => "Group",
            "type-id" => "e431f5f6-b5d2-343d-8b36-72607fffb74b",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => "1998",
                end => JSON::null,
                ended => JSON::false,
            },
            releases => [
                {
                    id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
                    title => "the Love Bug",
                    date => "2004-03-17",
                    "text-representation" => { "language" => "eng", "script" => "Latn" },
                    country => "JP",
                    disambiguation => "",
                    packaging => JSON::null,
                    "packaging-id" => JSON::null,
                    quality => "normal",
                    status => "Official",
                    "status-id" => "4e304316-386d-3409-af2e-78857eec5cfe",
                    barcode => "4988064451180",
                    "release-events" => [{
                        date => "2004-03-17",
                        "area" => {
                            disambiguation => '',
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }]
                }
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'various artists release lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'various artists release lookup',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=releases+various-artists&status=official' =>
        {
            id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
            name => "BoA",
            "sort-name" => "BoA",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => "1986-11-05",
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            releases => [
                {
                    id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
                    title => "the Love Bug",
                    packaging => JSON::null,
                    "packaging-id" => JSON::null,
                    status => "Official",
                    "status-id" => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { "language" => "eng", "script" => "Latn" },
                    date => "2004-03-17",
                    country => "JP",
                    "release-events" => [{
                        date => "2004-03-17",
                        "area" => {
                            disambiguation => '',
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4988064451180",
                    disambiguation => "",
                }
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'artist lookup with works (using l_artist_work)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with works (using l_artist_work)',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=works' =>
        {
            id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
            name => "Distance",
            "sort-name" => "Distance",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "UK dubstep artist Greg Sanders",
            "life-span" => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            works => [
                {
                    attributes => [],
                    id => "f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8",
                    title => "Asseswaving",
                    disambiguation => "",
                    iswcs => [],
                    language => 'jpn',
                    languages => ['jpn'],
                    type => JSON::null,
                    "type-id" => JSON::null,
                }
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};

test 'artist lookup with works (using l_recording_work)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with works (using l_recording_work)',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=works' =>
        {
            id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
            name => "BoA",
            "sort-name" => "BoA",
            country => JSON::null,
            area => JSON::null,
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => "1986-11-05",
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            works => [
                {
                    attributes => [],
                    id => "53d1fbac-e60a-38cb-85ff-e5a9224c9749",
                    title => "Be the one",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "303f9bd2-152f-3145-9e09-afa34edb6a57",
                    title => "DOUBLE",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "286ecfdd-2ffe-3bc7-b3e9-04cc8cea229b",
                    title => "Easy To Be Hard",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "7e78f281-52b4-315b-9d7b-6d215732f3d7",
                    title => "EXPECT",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "f23ae726-0300-3830-b1ca-634f4362f78c",
                    title => "LOVE & HONESTY",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "6f08d5a8-1811-3e5e-848b-35ffa77babe5",
                    title => "Midnight Parade",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "50c07b24-7ee2-31ac-ab87-f0d399011c71",
                    title => "Milky Way 〜君の歌〜",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "511f5124-c0ae-3386-bb76-4b6521498a68",
                    title => "Milky Way-君の歌-",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "d2f1ea1f-de2e-3d0c-b534-e96377912478",
                    title => "OVER～across the time～",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "61ab56f0-e803-3aef-a91b-63564b7a8043",
                    title => "Rock With You",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "7981d409-8e76-33df-be27-ef625d81c501",
                    title => "Shine We Are!",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "4b6a46c2-a904-3471-9bff-3942d4549f47",
                    title => "SOME DAY ONE DAY )",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "cd86f9e2-83ce-3192-a817-fe6c98079303",
                    title => "Song With No Name～名前のない歌～",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "46724ef1-241e-3d7f-9f3b-e51ba34e2aa1",
                    title => "the Love Bug",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
                {
                    attributes => [],
                    id => "2d967c29-63dc-309d-bbc1-a2d38639aaa1",
                    title => "心の手紙",
                    disambiguation => "",
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    "type-id" => JSON::null,
                },
            ],
            ipis => [],
            isnis => [],
            gender => JSON::null,
            "gender-id" => JSON::null,
        };
};


test 'artist lookup with artist relations' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'artist lookup with artist relations',
    '/artist/678ba12a-e485-44c7-8eaf-25e61a78a61b?inc=artist-rels' =>
        {
            id => "678ba12a-e485-44c7-8eaf-25e61a78a61b",
            name => "後藤真希",
            "sort-name" => "Goto, Maki",
            country => "JP",
            "area" => {
                disambiguation => '',
                "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                "name" => "Japan",
                "sort-name" => "Japan",
                "iso-3166-1-codes" => ["JP"],
                "type" => JSON::null,
                "type-id" => JSON::null,
            },
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            begin_area => JSON::null,
            end_area => JSON::null,
            disambiguation => "",
            "life-span" => {
                begin => "1985-09-23",
                end => JSON::null,
                ended => JSON::false,
            },
            type => "Person",
            "type-id" => "b6e035f4-3ce9-331c-97df-83397230b0df",
            relations => [
                {
                    attributes => [],
                    "attribute-ids" => {},
                    "attribute-values" => {},
                    type => 'member of band',
                    'type-id' => '5be4c609-9afa-4ea0-910b-12ffb71e3821',
                    direction => 'forward',
                    artist => {
                        id => "802673f0-9b88-4e8a-bb5c-dd01d68b086f",
                        name => "7人祭",
                        "sort-name" => "7nin Matsuri",
                        disambiguation => "",
                        type => "Group",
                        "type-id" => "e431f5f6-b5d2-343d-8b36-72607fffb74b",
                    },
                    'source-credit' => 'Maki Goto',
                    'target-credit' => '7nin Matsuri',
                    begin => '2001',
                    end => JSON::null,
                    ended => JSON::false,
                    'target-type' => 'artist',
                }
            ],
            ipis => [],
            isnis => [],
            gender => 'Female',
            "gender-id" => "93452b5a-a947-30c8-934f-6a4056b151c2",
        };
};

1;
