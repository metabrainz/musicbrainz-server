package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupReleaseGroup;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic release group lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic release group lookup',
    '/release-group/b84625af-6229-305f-9f1b-59c0185df016' => encode_json (
        {
            id => "b84625af-6229-305f-9f1b-59c0185df016",
            title => "サマーれげぇ!レインボー",
            disambiguation => "",
            "first-release-date" => "2001-07-04",
            "primary-type" => "Single",
            "secondary-types" => [],
        });
};

test 'release group lookup with releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release group lookup with releases',
    '/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2?inc=releases' => encode_json (
        {
            id => "56683a0b-45b8-3664-a231-5b68efe2e7e2",
            title => "Repercussions",
            "first-release-date" => "2008-11-17",
            "primary-type" => "Album",
            "secondary-types" => [ "Remix" ],
            releases => [
                {
                    id => "3b3d130a-87a8-4a47-b9fb-920f2530d134",
                    title => "Repercussions",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    date => "2008-11-17",
                    country => "GB",
                    barcode => "600116822123",
                    packaging => JSON::null,
                    asin => JSON::null,
                    disambiguation => "",
                }],
            disambiguation => "",
        });
};

test 'release group lookup with artists' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release group lookup with artists',
    '/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2?inc=artists' => encode_json (
        {
            id => "56683a0b-45b8-3664-a231-5b68efe2e7e2",
            title => "Repercussions",
            "first-release-date" => "2008-11-17",
            "primary-type" => "Album",
            "secondary-types" => [ "Remix" ],
            "artist-credit" => [
                {
                    name => "Distance",
                    artist => {
                        id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
                        name => "Distance",
                        "sort-name" => "Distance",
                        disambiguation => "UK dubstep artist Greg Sanders",
                    },
                    joinphrase => "",
                }],
            disambiguation => "",
        });
};

test 'release group lookup with inc=artists+releases+tags+ratings' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release group lookup with inc=artists+releases+tags+ratings',
    '/release-group/153f0a09-fead-3370-9b17-379ebd09446b?inc=artists+releases+tags+ratings' => encode_json (
        {
            id => "153f0a09-fead-3370-9b17-379ebd09446b",
            title => "the Love Bug",
            "first-release-date" => "2004-03-17",
            "primary-type" => "Single",
            "secondary-types" => [],
            "artist-credit" => [
                {
                    name => "m-flo",
                    artist => {
                        id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                        name => "m-flo",
                        "sort-name" => "m-flo",
                        disambiguation => "",
                    },
                    joinphrase => "",
                }],
            releases => [
                {
                    id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
                    title => "the Love Bug",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    date => "2004-03-17",
                    country => "JP",
                    barcode => "4988064451180",
                    asin => JSON::null,
                    packaging => JSON::null,
                    disambiguation => "",
                }],
            disambiguation => "",
            rating => { "votes-count" => 0, value => JSON::null },
            tags => [],
        });
};

test 'release group lookup with pseudo-releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release group lookup with pseudo-releases',
    '/release-group/153f0a09-fead-3370-9b17-379ebd09446b?inc=artists+releases&status=pseudo-release' => encode_json (
        {
            id => "153f0a09-fead-3370-9b17-379ebd09446b",
            title => "the Love Bug",
            "first-release-date" => "2004-03-17",
            "primary-type" => "Single",
            "secondary-types" => [],
            "artist-credit" => [
                {
                    name => "m-flo",
                    artist => {
                        id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                        name => "m-flo",
                        "sort-name" => "m-flo",
                        disambiguation => "",
                    },
                    joinphrase => "",
                }],
            releases => [],
            disambiguation => "",
        });
};

1;
