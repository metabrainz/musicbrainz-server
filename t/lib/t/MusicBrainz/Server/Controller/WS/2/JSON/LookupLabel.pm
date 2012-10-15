package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupLabel;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic label lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic label lookup',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b' => encode_json (
        {
            id => "b4edce40-090f-4956-b82a-5d9d285da40b",
            name => "Planet Mu",
            "sort-name" => "Planet Mu",
            type => "Original Production",
            disambiguation => "",
            "label-code" => JSON::null,
            country => "GB",
            "life-span" => {
                "begin" => "1995",
                "ended" => JSON::false,
            },
        });

};

test 'label lookup, inc=aliases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'label lookup, inc=aliases',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=aliases' => encode_json (
        {
            id => "b4edce40-090f-4956-b82a-5d9d285da40b",
            name => "Planet Mu",
            "sort-name" => "Planet Mu",
            type => "Original Production",
            disambiguation => "",
            "label-code" => JSON::null,
            country => "GB",
            "life-span" => {
                "begin" => "1995",
                "ended" => JSON::false,
            },
            aliases => [ { name => "Planet µ", "sort-name" => "Planet µ" } ]
        });

};

test 'label lookup with releases, inc=media' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'label lookup with releases, inc=media',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=releases+media' => encode_json (
        {
            id => "b4edce40-090f-4956-b82a-5d9d285da40b",
            name => "Planet Mu",
            "sort-name" => "Planet Mu",
            type => "Original Production",
            disambiguation => "",
            "label-code" => JSON::null,
            country => "GB",
            "life-span" => {
                "begin" => "1995",
                "ended" => JSON::false,
            },
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
                    asin => JSON::null,
                    disambiguation => "",
                    packaging => JSON::null,
                    media => [
                        { format => "CD", "track-count" => 9, title => JSON::null },
                        { format => "CD", "track-count" => 9, title => "Chestplate Singles" },
                    ],
                },
                {
                    id => "adcf7b48-086e-48ee-b420-1001f88d672f",
                    title => "My Demons",
                    status => "Official",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    date => "2007-01-29",
                    country => "GB",
                    barcode => "600116817020",
                    asin => JSON::null,
                    disambiguation => "",
                    packaging => JSON::null,
                    media => [ { format => "CD", "track-count" => 12, title => JSON::null } ]
                }
            ]
        });
};

1;

