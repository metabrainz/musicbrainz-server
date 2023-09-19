package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseReleaseGroups;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'browse release group via release' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse release group via release',
    '/release-group?release=adcf7b48-086e-48ee-b420-1001f88d672f&inc=artist-credits+tags+genres+ratings' =>
        {
            'release-group-offset' => 0,
            'release-group-count' => 1,
            'release-groups' => [
                {
                    id => '22b54315-6e51-350b-bb34-e6e16f7688bd',
                    title => 'My Demons',
                    'first-release-date' => '2007-01-29',
                    'primary-type' => 'Album',
                    'primary-type-id' => 'f529b476-6e62-324f-b0aa-1f3e33d313fc',
                    'secondary-types' => [],
                    'secondary-type-ids' => [],
                    'artist-credit' => [
                        {
                            name => 'Distance',
                            artist => {
                                id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
                                name => 'Distance',
                                'sort-name' => 'Distance',
                                disambiguation => 'UK dubstep artist Greg Sanders',
                                tags => [],
                                genres => [],
                                'type' => 'Person',
                                'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
                            },
                            joinphrase => '',
                        }],
                    tags => [
                        { count => 2, name => 'dubstep' },
                        { count => 1, name => 'electronic' },
                        { count => 1, name => 'grime' }],
                    genres => [
                        { count => 2, disambiguation => '', id => '1b50083b-1afa-4778-82c8-548b309af783', name => 'dubstep' },
                        { count => 1, disambiguation => '', id => '89255676-1f14-4dd8-bbad-fca839d6aff4', name => 'electronic' },
                        { count => 1, disambiguation => 'stuff', id => '51cfaac4-6696-480b-8f1b-27cfc789109c', name => 'grime' }],
                    'rating' => { 'votes-count' => 1, 'value' => 4 },
                    disambiguation => '',
                }]
        };
};

test 'browse release group via artist' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse release group via artist',
    '/release-group?artist=472bc127-8861-45e8-bc9e-31e8dd32de7a&inc=artist-credits+tags+genres+ratings' =>
        {
            'release-group-count' => 2,
            'release-group-offset' => 0,
            'release-groups' => [
                {
                    id => '22b54315-6e51-350b-bb34-e6e16f7688bd',
                    title => 'My Demons',
                    'first-release-date' => '2007-01-29',
                    'primary-type' => 'Album',
                    'primary-type-id' => 'f529b476-6e62-324f-b0aa-1f3e33d313fc',
                    'secondary-types' => [],
                    'secondary-type-ids' => [],
                    'artist-credit' => [
                        {
                            name => 'Distance',
                            artist => {
                                id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
                                name => 'Distance',
                                'sort-name' => 'Distance',
                                disambiguation => 'UK dubstep artist Greg Sanders',
                                tags => [],
                                genres => [],
                                'type' => 'Person',
                                'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
                            },
                            joinphrase => '',
                        }],
                    tags => [
                        { count => 2, name => 'dubstep' },
                        { count => 1, name => 'electronic' },
                        { count => 1, name => 'grime' }],
                    genres => [
                        { count => 2, disambiguation => '', id => '1b50083b-1afa-4778-82c8-548b309af783', name => 'dubstep' },
                        { count => 1, disambiguation => '', id => '89255676-1f14-4dd8-bbad-fca839d6aff4', name => 'electronic' },
                        { count => 1, disambiguation => 'stuff', id => '51cfaac4-6696-480b-8f1b-27cfc789109c', name => 'grime' }],
                    'rating' => { 'votes-count' => 1, 'value' => 4 },
                    disambiguation => '',
                },
                {
                    id => '56683a0b-45b8-3664-a231-5b68efe2e7e2',
                    title => 'Repercussions',
                    'first-release-date' => '2008-11-17',
                    'primary-type' => 'Album',
                    'primary-type-id' => 'f529b476-6e62-324f-b0aa-1f3e33d313fc',
                    'secondary-types' => [ 'Remix' ],
                    'secondary-type-ids' => [ '0c60f497-ff81-3818-befd-abfc84a4858b' ],
                    'artist-credit' => [
                        {
                            name => 'Distance',
                            artist => {
                                id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
                                name => 'Distance',
                                'sort-name' => 'Distance',
                                disambiguation => 'UK dubstep artist Greg Sanders',
                                tags => [],
                                genres => [],
                                'type' => 'Person',
                                'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
                            },
                            joinphrase => '',
                        }],
                    tags => [ ],
                    genres => [ ],
                    'rating' => { 'votes-count' => 0, 'value' => JSON::null },
                    disambiguation => '',
                }]
        };
};

test 'browse singles via artist' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse singles via artist',
    '/release-group?artist=a16d1433-ba89-4f72-a47b-a370add0bb55&type=single' =>
        {
            'release-group-count' => 0,
            'release-group-offset' => 0,
            'release-groups' => []
        };
};

test 'browse official release groups via artist' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse release group via artist',
    '/release-group?artist=472bc127-8861-45e8-bc9e-31e8dd32de7a&release-group-status=website-default&inc=artist-credits+tags+genres+ratings' =>
        {
            'release-group-count' => 1,
            'release-group-offset' => 0,
            'release-groups' => [
                {
                    id => '22b54315-6e51-350b-bb34-e6e16f7688bd',
                    title => 'My Demons',
                    'first-release-date' => '2007-01-29',
                    'primary-type' => 'Album',
                    'primary-type-id' => 'f529b476-6e62-324f-b0aa-1f3e33d313fc',
                    'secondary-types' => [],
                    'secondary-type-ids' => [],
                    'artist-credit' => [
                        {
                            name => 'Distance',
                            artist => {
                                id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
                                name => 'Distance',
                                'sort-name' => 'Distance',
                                disambiguation => 'UK dubstep artist Greg Sanders',
                                tags => [],
                                genres => [],
                                'type' => 'Person',
                                'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
                            },
                            joinphrase => '',
                        }],
                    tags => [
                        { count => 2, name => 'dubstep' },
                        { count => 1, name => 'electronic' },
                        { count => 1, name => 'grime' }],
                    genres => [
                        { count => 2, disambiguation => '', id => '1b50083b-1afa-4778-82c8-548b309af783', name => 'dubstep' },
                        { count => 1, disambiguation => '', id => '89255676-1f14-4dd8-bbad-fca839d6aff4', name => 'electronic' },
                        { count => 1, disambiguation => 'stuff', id => '51cfaac4-6696-480b-8f1b-27cfc789109c', name => 'grime' }],
                    'rating' => { 'votes-count' => 1, 'value' => 4 },
                    disambiguation => '',
                }]
        };
};

1;

