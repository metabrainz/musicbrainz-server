package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseEvents;

use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws_test_json );

with 't::Mechanize', 't::Context';

test 'browse events via events' => sub {
    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+event');

    ws_test_json 'browse events via event',
        '/event?event=183ba1ec-a87b-4c0e-85dd-496b7cea4399' =>
        {
            'event-count' => 5,
            'event-offset' => 0,
            events => [
                {
                    cancelled => JSON::false,
                    disambiguation => '',
                    id => '183ba1ec-a87b-4c0e-85dd-496b7cea4399',
                    'life-span' => {
                        begin => '2024-07-31',
                        end => '2024-08-03',
                        ended => JSON::true,
                    },
                    name => 'Wacken Open Air 2024',
                    setlist => '',
                    time => '',
                    type => 'Festival',
                    'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
                },
                {
                    cancelled => JSON::false,
                    disambiguation => '',
                    id => '3495abf6-4692-45cd-af62-7d964558676a',
                    'life-span' => {
                        begin => '2024-07-29',
                        end => '2024-07-29',
                        ended => JSON::true,
                    },
                    name => 'Wacken Open Air 2024, Day 2',
                    setlist => '',
                    time => '',
                    type => 'Festival',
                    'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
                },
                {
                    cancelled => JSON::false,
                    disambiguation => '',
                    id => '6b67008c-55a1-44a4-98be-ecfdebc18987',
                    'life-span' => {
                        begin => '2024-07-30',
                        end => '2024-07-30',
                        ended => JSON::true,
                    },
                    name => 'Wacken Open Air 2024, Day 3',
                    setlist => '',
                    time => '',
                    type => 'Festival',
                    'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
                },
                {
                    cancelled => JSON::false,
                    disambiguation => '',
                    id => 'eddb272f-1f10-4ece-875d-52cd0d3a2bb1',
                    'life-span' => {
                        begin => '2024-07-30',
                        end => '2024-07-30',
                        ended => JSON::true,
                    },
                    name => 'Wacken Open Air 2024, Day 3: LGH Clubstage',
                    setlist => '',
                    time => '',
                    type => 'Festival',
                    'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
                },
                {
                    cancelled => JSON::false,
                    disambiguation => '',
                    id => 'f0ecc038-d229-4b3e-aa98-d5f4de693272',
                    'life-span' => {
                        begin => '2024-07-29',
                        end => '2024-07-29',
                        ended => JSON::true,
                    },
                    name => 'Wacken Open Air 2024, Day 2: Welcome to the Jungle',
                    setlist => '',
                    time => '',
                    type => 'Festival',
                    'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
                },
            ],
        };
};

test 'browse events via series' => sub {
    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+event');

    ws_test_json 'browse events via series, inc=place-rels',
        '/event?series=d977f7fd-96c9-4e3e-83b5-eb484a9e6584&inc=place-rels' =>
        {
            'event-count' => 2,
            'event-offset' => 0,
            events => [
                {
                    cancelled => JSON::false,
                    disambiguation => '',
                    id => '183ba1ec-a87b-4c0e-85dd-496b7cea4399',
                    'life-span' => {
                        begin => '2024-07-31',
                        end => '2024-08-03',
                        ended => JSON::true,
                    },
                    name => 'Wacken Open Air 2024',
                    setlist => '',
                    time => '',
                    type => 'Festival',
                    'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
                    relations => [],
                },
                {
                    cancelled => JSON::false,
                    disambiguation => '2022, Prom 60',
                    id => 'ca1d24c1-1999-46fd-8a95-3d4108df5cb2',
                    'life-span' => {
                        begin => '2022-09-01',
                        end => '2022-09-01',
                        ended => JSON::true,
                    },
                    name => 'BBC Open Music Prom',
                    setlist => '',
                    time => '19:30',
                    type => 'Concert',
                    'type-id' => 'ef55e8d7-3d00-394a-8012-f5506a29ff0b',
                    relations => [{
                        'attribute-values' => { },
                        'attribute-ids' => { },
                        attributes => [ ],
                        place => {
                            area => {
                                id => 'b9576171-3434-4d1b-8883-165ed6e65d2f',
                                disambiguation => '',
                                'type-id' => 'fd3d44c5-80a1-3842-9745-2c4972d35afa',
                                name => 'Kensington and Chelsea',
                                type => 'Subdivision',
                                'sort-name' => 'Kensington and Chelsea',
                            },
                            disambiguation => '',
                            name => 'Royal Albert Hall',
                            'type-id' => 'cd92781a-a73f-30e8-a430-55d7521338db',
                            type => 'Venue',
                            id => '4352063b-a833-421b-a420-e7fb295dece0',
                            address => 'Kensington Gore, London SW7 2AP',
                            coordinates => {
                                latitude => 51.50105,
                                longitude => -0.17748,
                            },
                        },
                        type => 'held at',
                        'target-type' => 'place',
                        ended => JSON::false,
                        begin => JSON::null,
                        end => JSON::null,
                        'source-credit' => '',
                        'target-credit' => '',
                        'type-id' => 'e2c6f697-07dc-38b1-be0b-83d740165532',
                        direction => 'forward',
                    }],
                },
            ],
        };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
