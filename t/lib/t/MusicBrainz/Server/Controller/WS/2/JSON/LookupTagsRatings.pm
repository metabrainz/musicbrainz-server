package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupTagsRatings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'artist lookups' => sub {
    my $c = shift->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws_test_json 'artist lookup with tags, genres and ratings',
        '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=tags+genres+ratings' => {
            'isnis' => [],
            'name' => 'BoA',
            'begin_area' => JSON::null,
            'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
            'type' => 'Person',
            'id' => 'a16d1433-ba89-4f72-a47b-a370add0bb55',
            'life-span' => {
                'ended' => JSON::false,
                'begin' => '1986-11-05',
                'end' => JSON::null
            },
            'rating' => {
                'value' => '4.35',
                'votes-count' => 3
            },
            'genres' => [
                {
                    'name' => 'j-pop',
                    'disambiguation' => '',
                    'count' => 1,
                    'id' => 'eba7715e-ee26-4989-8d49-9db382955419'
                },
                {
                    'name' => 'k-pop',
                    'disambiguation' => '',
                    'id' => 'b74b3b6c-0700-46b1-aa55-1f2869a3bd1a',
                    'count' => 1
                },
                {
                    'count' => 1,
                    'id' => '911c7bbb-172d-4df8-9478-dbff4296e791',
                    'name' => 'pop',
                    'disambiguation' => ''
                }
            ],
            'area' => JSON::null,
            'sort-name' => 'BoA',
            'gender' => JSON::null,
            'end-area' => JSON::null,
            'begin-area' => JSON::null,
            'end_area' => JSON::null,
            'tags' => [
                {
                    'count' => 1,
                    'name' => 'c-pop'
                },
                {
                    'name' => 'j-pop',
                    'count' => 1
                },
                {
                    'name' => 'japanese',
                    'count' => 1
                },
                {
                    'name' => 'jpop',
                    'count' => 1
                },
                {
                    'name' => 'k-pop',
                    'count' => 1
                },
                {
                    'count' => 1,
                    'name' => 'kpop'
                },
                {
                    'name' => 'pop',
                    'count' => 1
                }
            ],
            'disambiguation' => '',
            'ipis' => [],
            'gender-id' => JSON::null,
            'country' => JSON::null
        };

    ws_test_json 'artist lookup with tags, genres, user-tags, and user-genres',
        '/artist/1946a82a-f927-40c2-8235-38d64f50d043?inc=tags+genres+user-tags+user-genres' => {
            'gender-id' => JSON::null,
            'sort-name' => 'Chemical Brothers, The',
            'begin-area' => JSON::null,
            'end-area' => JSON::null,
            'gender' => JSON::null,
            'begin_area' => JSON::null,
            'isnis' => [],
            'type-id' => 'e431f5f6-b5d2-343d-8b36-72607fffb74b',
            'genres' => [
                {
                    'name' => 'big beat',
                    'id' => 'aac07ae0-8acf-4249-b5c0-2762b53947a2',
                    'count' => 4,
                    'disambiguation' => ''
                },
                {
                    'id' => '89255676-1f14-4dd8-bbad-fca839d6aff4',
                    'count' => 8,
                    'disambiguation' => '',
                    'name' => 'electronic'
                },
                {
                    'id' => '53a3cea3-17af-4421-a07a-5824b540aeb5',
                    'count' => 2,
                    'disambiguation' => '',
                    'name' => 'electronica'
                },
                {
                    'name' => 'house',
                    'disambiguation' => '',
                    'count' => 1,
                    'id' => 'a2782cb6-1cd0-477c-a61d-b3f8b42dd1b3'
                }
            ],
            'type' => 'Group',
            'tags' => [
                {
                    'count' => 4,
                    'name' => 'big beat'
                },
                {
                    'name' => 'british',
                    'count' => 6
                },
                {
                    'name' => 'dance and electronica',
                    'count' => 1
                },
                {
                    'name' => 'electronic',
                    'count' => 8
                },
                {
                    'count' => 2,
                    'name' => 'electronica'
                },
                {
                    'count' => 1,
                    'name' => 'english'
                },
                {
                    'name' => 'house',
                    'count' => 1
                },
                {
                    'count' => 1,
                    'name' => 'manchester'
                },
                {
                    'count' => 1,
                    'name' => 'trip-hop'
                },
                {
                    'count' => 1,
                    'name' => 'uk'
                },
                {
                    'name' => 'united kingdom',
                    'count' => 1
                }
            ],
            'name' => 'The Chemical Brothers',
            'end_area' => JSON::null,
            'user-tags' => [
                {
                    'name' => 'big beat'
                },
                {
                    'name' => 'electronic'
                }
            ],
            'user-genres' => [
                {
                    'name' => 'big beat',
                    'disambiguation' => '',
                    'id' => 'aac07ae0-8acf-4249-b5c0-2762b53947a2'
                },
                {
                    'id' => '89255676-1f14-4dd8-bbad-fca839d6aff4',
                    'disambiguation' => '',
                    'name' => 'electronic'
                }
            ],
            'id' => '1946a82a-f927-40c2-8235-38d64f50d043',
            'ipis' => [],
            'area' => JSON::null,
            'life-span' => {
                'ended' => JSON::false,
                'end' => JSON::null,
                'begin' => '1989'
            },
            'disambiguation' => '',
            'country' => JSON::null
        },  { username => 'the-anti-kuno', password => 'notreally' };

    ws_test_json 'artist lookup with release-groups, tags, genres and ratings',
        '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=release-groups+tags+genres+ratings' => {
            'begin-area' => JSON::null,
            'tags' => [
                {
                    'count' => 1,
                    'name' => 'c-pop'
                },
                {
                    'count' => 1,
                    'name' => 'j-pop'
                },
                {
                    'count' => 1,
                    'name' => 'japanese'
                },
                {
                    'count' => 1,
                    'name' => 'jpop'
                },
                {
                    'name' => 'k-pop',
                    'count' => 1
                },
                {
                    'count' => 1,
                    'name' => 'kpop'
                },
                {
                    'count' => 1,
                    'name' => 'pop'
                }
            ],
            'gender' => JSON::null,
            'isnis' => [],
            'begin_area' => JSON::null,
            'country' => JSON::null,
            'ipis' => [],
            'disambiguation' => '',
            'name' => 'BoA',
            'sort-name' => 'BoA',
            'life-span' => {
                'ended' => JSON::false,
                'end' => JSON::null,
                'begin' => '1986-11-05'
            },
            'gender-id' => JSON::null,
            'genres' => [
                {
                    'id' => 'eba7715e-ee26-4989-8d49-9db382955419',
                    'name' => 'j-pop',
                    'count' => 1,
                    'disambiguation' => ''
                },
                {
                    'id' => 'b74b3b6c-0700-46b1-aa55-1f2869a3bd1a',
                    'name' => 'k-pop',
                    'disambiguation' => '',
                    'count' => 1
                },
                {
                    'id' => '911c7bbb-172d-4df8-9478-dbff4296e791',
                    'name' => 'pop',
                    'disambiguation' => '',
                    'count' => 1
                }
            ],
            'type' => 'Person',
            'id' => 'a16d1433-ba89-4f72-a47b-a370add0bb55',
            'end-area' => JSON::null,
            'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
            'rating' => {
                'votes-count' => 3,
                'value' => '4.35'
            },
            'area' => JSON::null,
            'end_area' => JSON::null,
            'release-groups' => [
                {
                    'primary-type-id' => 'f529b476-6e62-324f-b0aa-1f3e33d313fc',
                    'primary-type' => 'Album',
                    'title' => 'LOVE & HONESTY',
                    'secondary-types' => [],
                    'id' => '23f421e7-431e-3e1d-bcbf-b91f5f7c5e2c',
                    'first-release-date' => '2004-01-15',
                    'genres' => [],
                    'disambiguation' => '',
                    'secondary-type-ids' => [],
                    'tags' => [
                        {
                            'name' => 'format-dvd-video',
                            'count' => 1
                        }
                    ]
                }
            ]
        };
};

1;

