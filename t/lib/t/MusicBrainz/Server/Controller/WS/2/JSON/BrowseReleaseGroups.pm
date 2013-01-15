package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseReleaseGroups;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'browse release group via release' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse release group via release',
    '/release-group?release=adcf7b48-086e-48ee-b420-1001f88d672f&inc=artist-credits+tags+ratings' => encode_json (
        {
            "release-group-offset" => 0,
            "release-group-count" => 1,
            "release-groups" => [
                {
                    id => "22b54315-6e51-350b-bb34-e6e16f7688bd",
                    title => "My Demons",
                    "first-release-date" => "2007-01-29",
                    "primary-type" => "Album",
                    "secondary-types" => [],
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
                    tags => [
                        { count => 2, name => "dubstep" },
                        { count => 1, name => "electronic" },
                        { count => 1, name => "grime" }],
                    "rating" => { "votes-count" => 1, "value" => 4 },
                    disambiguation => "",
                }]
        });
};

test 'browse release group via artist' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse release group via artist',
    '/release-group?artist=472bc127-8861-45e8-bc9e-31e8dd32de7a&inc=artist-credits+tags+ratings' => encode_json (
        {
            "release-group-count" => 2,
            "release-group-offset" => 0,
            "release-groups" => [
                {
                    id => "22b54315-6e51-350b-bb34-e6e16f7688bd",
                    title => "My Demons",
                    "first-release-date" => "2007-01-29",
                    "primary-type" => "Album",
                    "secondary-types" => [],
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
                    tags => [
                        { count => 2, name => "dubstep" },
                        { count => 1, name => "electronic" },
                        { count => 1, name => "grime" }],
                    "rating" => { "votes-count" => 1, "value" => 4 },
                    disambiguation => "",
                },
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
                    tags => [ ],
                    "rating" => { "votes-count" => 0, "value" => JSON::null },
                    disambiguation => "",
                }]
        });
};

test 'browse singles via artist' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse singles via artist',
    '/release-group?artist=a16d1433-ba89-4f72-a47b-a370add0bb55&type=single' => encode_json (
        {
            "release-group-count" => 0,
            "release-group-offset" => 0,
            "release-groups" => []
        });
};

1;

