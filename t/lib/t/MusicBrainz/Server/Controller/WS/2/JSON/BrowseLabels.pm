package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseLabels;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'browse labels via release' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse labels via release',
    '/label?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7' => encode_json (
        {
            "label-count" => 1,
            "label-offset" => 0,
            labels => [
                {
                    type => "Original Production",
                    id => "72a46579-e9a0-405a-8ee1-e6e6b63b8212",
                    name => "rhythm zone",
                    "sort-name" => "rhythm zone",
                    country => "JP",
                    "area" => {
                        "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                        "name" => "Japan",
                        "sort-name" => "Japan",
                        "iso_3166_1_codes" => ["JP"],
                        "iso_3166_2_codes" => [],
                        "iso_3166_3_codes" => []},
                    "life-span" => {
                        begin => JSON::null,
                        end => JSON::null,
                        ended => JSON::false,
                    },
                    disambiguation => "",
                    "label-code" => JSON::null,
                    ipis => [],
                }]
        });
};

1;
