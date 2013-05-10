package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupDiscID;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'direct disc id lookup' => sub {

    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
    MusicBrainz::Server::Test->prepare_test_database(
        $test->c, "INSERT INTO medium_cdtoc (medium, cdtoc) VALUES (2, 2);");

    ws_test_json 'direct disc id lookup',
    '/discid/IeldkVfIh1wep_M8CMuDvA0nQ7Q-' => encode_json (
        {
            id => "IeldkVfIh1wep_M8CMuDvA0nQ7Q-",
            sectors => 189343,
            releases => [
                {
                    id => "f205627f-b70a-409d-adbe-66289b614e80",
                    title => "Aerial",
                    quality => "normal",
                    date => "2007",
                    media => [
                        {
                            title => "A Sea of Honey",
                            format => "Format",
                            'track-count' => 7,
                            discs => [],
                        },
                        {
                            title => "A Sky of Honey",
                            format => "Format",
                            'track-count' => 9,
                            discs => [
                                {
                                    id => "IeldkVfIh1wep_M8CMuDvA0nQ7Q-",
                                    sectors => 189343,
                                }
                            ]
                        },
                    ],
                    'cover-art-archive' => {
                        artwork => JSON::false,
                        darkened => JSON::false,
                        front => JSON::false,
                        back => JSON::false,
                        count => 0,
                    },
                    asin => JSON::null,
                    barcode => JSON::null,
                    country => JSON::null,
                    disambiguation => '',
                    packaging => JSON::null,
                    status => JSON::null,
                    'text-representation' => { language => JSON::null, script => JSON::null },
                    "release-events" => [{
                        date => "2007",
                        area => JSON::null,
                    }]
                }
            ]
        });
};


test 'lookup via toc' => sub {

    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
    MusicBrainz::Server::Test->prepare_test_database(
        $test->c, "INSERT INTO medium_cdtoc (medium, cdtoc) VALUES (2, 2);");
    $test->c->model('DurationLookup')->update(2);
    $test->c->model('DurationLookup')->update(4);

    ws_test_json 'lookup via toc',
    '/discid/aa11.sPglQ1x0cybDcDi0OsZw9Q-?toc=1 9 189343 150 6614 32287 54041 61236 88129 92729 115276 153877&cdstubs=no' => encode_json (
        {
            releases => [
                {
                    id => "9b3d9383-3d2a-417f-bfbb-56f7c15f075b",
                    title => "Aerial",
                    quality => "normal",
                    date => "2008",
                    media => [
                        {
                            title => "A Sea of Honey",
                            format => "Format",
                            'track-count' => 7,
                            discs => [],
                        },
                        {
                            title => "A Sky of Honey",
                            format => "Format",
                            'track-count' => 9,
                            discs => [],
                        },
                    ],
                    'cover-art-archive' => {
                        artwork => JSON::false,
                        darkened => JSON::false,
                        front => JSON::false,
                        back => JSON::false,
                        count => 0,
                    },
                    asin => JSON::null,
                    barcode => JSON::null,
                    country => JSON::null,
                    disambiguation => '',
                    packaging => JSON::null,
                    status => JSON::null,
                    'text-representation' => { language => JSON::null, script => JSON::null },
                    "release-events" => [{
                        date => "2008",
                        area => JSON::null,
                    }]
                },
                {
                    id => "f205627f-b70a-409d-adbe-66289b614e80",
                    title => "Aerial",
                    quality => "normal",
                    date => "2007",
                    media => [
                        {
                            title => "A Sea of Honey",
                            format => "Format",
                            'track-count' => 7,
                            discs => [],
                        },
                        {
                            title => "A Sky of Honey",
                            format => "Format",
                            'track-count' => 9,
                            discs => [
                                {
                                    id => "IeldkVfIh1wep_M8CMuDvA0nQ7Q-",
                                    sectors => 189343,
                                }
                            ]
                        },
                    ],
                    'cover-art-archive' => {
                        artwork => JSON::false,
                        darkened => JSON::false,
                        front => JSON::false,
                        back => JSON::false,
                        count => 0,
                    },
                    asin => JSON::null,
                    barcode => JSON::null,
                    country => JSON::null,
                    disambiguation => '',
                    packaging => JSON::null,
                    status => JSON::null,
                    'text-representation' => { language => JSON::null, script => JSON::null },
                    "release-events" => [{
                        date => "2007",
                        area => JSON::null,
                    }]
                }
            ]
        });
};

1;

