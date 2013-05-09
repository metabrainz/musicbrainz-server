package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseArtists;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'browse artists via release group' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse artists via release group',
    '/artist?release-group=22b54315-6e51-350b-bb34-e6e16f7688bd' => encode_json (
        {
            "artist-offset" => 0,
            "artist-count" => 1,
            artists => [
                {
                    id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
                    name => "Distance",
                    "sort-name" => "Distance",
                    country => JSON::null,
                    area => JSON::null,
                    begin_area => JSON::null,
                    end_area => JSON::null,
                    disambiguation => "UK dubstep artist Greg Sanders",
                    "life-span" => {
                        begin => JSON::null,
                        end => JSON::null,
                        ended => JSON::false,
                    },
                    type => "Person",
                    ipis => [],
                }]
        });
};

test 'browse artists via recording' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse artists via recording',
    '/artist?inc=aliases&recording=0cf3008f-e246-428f-abc1-35f87d584d60' => encode_json (
        {
            "artist-offset" => 0,
            "artist-count" => 2,
            artists => [
                {
                    id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                    name => "m-flo",
                    "sort-name" => "m-flo",
                    country => JSON::null,
                    area => JSON::null,
                    begin_area => JSON::null,
                    end_area => JSON::null,
                    disambiguation => "",
                    "life-span" => {
                        begin => "1998",
                        end => JSON::null,
                        ended => JSON::false,
                    },
                    type => "Group",
                    aliases => [
                        { "sort-name" => "m-flow", name => "m-flow", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { "sort-name" => "mediarite-flow crew", name => "mediarite-flow crew", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { "sort-name" => "meteorite-flow crew", name => "meteorite-flow crew", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { "sort-name" => "mflo", name => "mflo", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { "sort-name" => "えむふろう", name => "えむふろう", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { "sort-name" => "エムフロウ", name => "エムフロウ", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        ],
                    ipis => [],
                },
                {
                    id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
                    name => "BoA",
                    "sort-name" => "BoA",
                    country => JSON::null,
                    area => JSON::null,
                    begin_area => JSON::null,
                    end_area => JSON::null,
                    disambiguation => "",
                    "life-span" => {
                        begin => "1986-11-05",
                        end => JSON::null,
                        ended => JSON::false,
                    },
                    type => "Person",
                    aliases => [
                        { name => "Beat of Angel", "sort-name" => "Beat of Angel", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { name => "BoA Kwon", "sort-name" => "BoA Kwon", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { name => "Kwon BoA", "sort-name" => "Kwon BoA", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { name => "ボア", "sort-name" => "ボア", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        { name => "보아", "sort-name" => "보아", locale => JSON::null, primary => JSON::null, type => JSON::null },
                        ],
                    ipis => [],
                }]
        });
};

test 'browse artists via release, inc=tags+ratings' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse artists via release, inc=tags+ratings',
    '/artist?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7&inc=tags+ratings' => encode_json (
        {
            "artist-offset" => 0,
            "artist-count" => 3,
            artists => [
                {
                    id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                    name => "m-flo",
                    "sort-name" => "m-flo",
                    country => JSON::null,
                    area => JSON::null,
                    begin_area => JSON::null,
                    end_area => JSON::null,
                    disambiguation => "",
                    "life-span" => {
                        begin => "1998",
                        end => JSON::null,
                        ended => JSON::false,
                    },
                    type => "Group",
                    rating => { "votes-count" => 3, "value" => 3 },
                    tags => [],
                    ipis => [],
                },
                {
                    id => "97fa3f6e-557c-4227-bc0e-95a7f9f3285d",
                    name => "BAGDAD CAFE THE trench town",
                    "sort-name" => "BAGDAD CAFE THE trench town",
                    country => JSON::null,
                    area => JSON::null,
                    begin_area => JSON::null,
                    end_area => JSON::null,
                    disambiguation => "",
                    "life-span" => {
                        begin => JSON::null,
                        end => JSON::null,
                        ended => JSON::false,
                    },
                    type => JSON::null,
                    rating => { "votes-count" => 0, "value" => JSON::null },
                    tags => [],
                    ipis => [],
                },
                {
                    id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
                    name => "BoA",
                    "sort-name" => "BoA",
                    country => JSON::null,
                    area => JSON::null,
                    begin_area => JSON::null,
                    end_area => JSON::null,
                    disambiguation => "",
                    type => "Person",
                    "life-span" => {
                        begin => "1986-11-05",
                        end => JSON::null,
                        ended => JSON::false,
                    },
                    rating => { "votes-count" => 3, "value" => 4.35 },
                    tags => [
                        { count => 1, name => 'c-pop' },
                        { count => 1, name => 'j-pop' },
                        { count => 1, name => 'japanese' },
                        { count => 1, name => 'jpop' },
                        { count => 1, name => 'k-pop' },
                        { count => 1, name => 'kpop' },
                        { count => 1, name => 'pop' },
                        ],
                    ipis => [],
                }]
        });
};

1;
