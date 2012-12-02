package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseRecordings;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'browse recordings via artist (first page)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse recordings via artist (first page)',
    '/recording?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&inc=puids&limit=3' => encode_json (
        {
            "recording-count" => 10,
            "recording-offset" => 0,
            recordings => [
                {
                    id => "4f392ffb-d3df-4f8a-ba74-fdecbb1be877",
                    title => "Busy Working",
                    length => 217440,
                    puids => [ "1d8cf2de-4e31-2043-cbb2-9d61d000e5da" ],
                    disambiguation => "",
                },
                {
                    id => "6f9c8c32-3aae-4dad-b023-56389361cf6b",
                    title => "Bibi Plone",
                    length => 173960,
                    puids => [ "a1f6892c-8cf4-150f-3e42-2d32c7652460" ],
                    disambiguation => "",
                },
                {
                    id => "7e379a1d-f2bc-47b8-964e-00723df34c8a",
                    title => "Be Rude to Your School",
                    length => 208706,
                    puids => [
                        "24dd0c12-3f22-955d-f35e-d3d8867eee8d",
                        "7038d263-9736-015b-e43d-4e6e7bb85138" ],
                    disambiguation => "",
                }]
        });
};

test 'browse recordings via artist (second page)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse recordings via artist (second page)',
    '/recording?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&inc=puids&limit=3&offset=3' => encode_json (
        {
            "recording-count" => 10,
            "recording-offset" => 3,
            recordings => [
                {
                    id => "44704dda-b877-4551-a2a8-c1f764476e65",
                    title => "On My Bus",
                    length => 267560,
                    puids => [
                        "138f0487-85eb-5fe9-355d-9b94a60ff1dc",
                        "59963809-99c6-86c8-246a-85c1779bed07" ],
                    disambiguation => "",
                },
                {
                    id => "6e89c516-b0b6-4735-a758-38e31855dcb6",
                    title => "Plock",
                    length => 237133,
                    puids => [
                        "138f0487-85eb-5fe9-355d-9b94a60ff1dc",
                        "e21f9f94-85cd-5e40-d158-0cea7e4b5877" ],
                    disambiguation => "",
                },
                {
                    id => "791d9b27-ae1a-4295-8943-ded4284f2122",
                    title => "Marbles",
                    length => 229826,
                    puids => [
                        "45aa205f-1fdb-b441-a97b-17d95c786cc0",
                        "53760233-32b0-09f6-131d-5f796ffd4b52" ],
                    disambiguation => "",
                }]
        });
};


test 'browse recordings via release' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse recordings via release',
    '/recording?release=adcf7b48-086e-48ee-b420-1001f88d672f&limit=4' => encode_json (
        {
            "recording-count" => 12,
            "recording-offset" => 0,
            recordings => [
                {
                    id => "7a356856-9483-42c2-bed9-dc07cb555952",
                    title => "Cella",
                    length => 334000,
                    disambiguation => "",
                },
                {
                    id => "9011e90d-b7e3-400b-b932-305f94608772",
                    title => "Delight",
                    length => 339000,
                    disambiguation => "",
                },
                {
                    id => "a4eb6323-519d-44e4-8ab7-df0a0f9df349",
                    title => "Cyclops",
                    length => 265000,
                    disambiguation => "",
                },
                {
                    id => "e5a5847b-451b-4051-a09b-8295329097e3",
                    title => "Confined",
                    length => 314000,
                    disambiguation => "",
                }]
        });
};

1;
