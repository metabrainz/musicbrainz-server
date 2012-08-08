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
            disambiguation => JSON::null,
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
            disambiguation => JSON::null,
            "label-code" => JSON::null,
            country => "GB",
            "life-span" => {
                "begin" => "1995",
                "ended" => JSON::false,
            },
            aliases => [ { name => "Planet µ", "sort-name" => "Planet µ" } ]
        });

};

1;

