package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseEvents;

use utf8;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use JSON;
use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws_test_json );

with 't::Mechanize', 't::Context';

test 'browse events via events' => sub {
    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+event');

    ws_test_json 'browse events via event',
        '/event?event=183ba1ec-a87b-4c0e-85dd-496b7cea4399' =>
        {
            'event-count' => 4,
            'event-offset' => 0,
            events => [
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

    ws_test_json 'browse events via multiple events, inc=event-rels',
        '/event?event=3495abf6-4692-45cd-af62-7d964558676a' .
            '&event=6b67008c-55a1-44a4-98be-ecfdebc18987&inc=event-rels' =>
        {
            'event-count' => 3,
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
                    relations => [
                        {
                            'attribute-ids' => {},
                            'attribute-values' => {},
                            attributes => [],
                            begin => JSON::null,
                            direction => 'forward',
                            end => JSON::null,
                            ended => JSON::false,
                            event => {
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
                            'source-credit' => '',
                            'target-credit' => '',
                            'target-type' => 'event',
                            type => 'parts',
                            'type-id' => '65742183-b25c-469e-b094-ff6739e6699c',
                        },
                        {
                            'attribute-ids' => {},
                            'attribute-values' => {},
                            attributes => [],
                            begin => JSON::null,
                            direction => 'forward',
                            end => JSON::null,
                            ended => JSON::false,
                            event => {
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
                            'source-credit' => '',
                            'target-credit' => '',
                            'target-type' => 'event',
                            type => 'parts',
                            'type-id' => '65742183-b25c-469e-b094-ff6739e6699c',
                        },
                    ],
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
                    relations => [
                        {
                            'attribute-ids' => {},
                            'attribute-values' => {},
                            attributes => [],
                            begin => JSON::null,
                            direction => 'backward',
                            end => JSON::null,
                            ended => JSON::false,
                            event => {
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
                            'source-credit' => '',
                            'target-credit' => '',
                            'target-type' => 'event',
                            type => 'parts',
                            'type-id' => '65742183-b25c-469e-b094-ff6739e6699c',
                        },
                    ],
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
                    relations => [
                        {
                            'attribute-ids' => {},
                            'attribute-values' => {},
                            attributes => [],
                            begin => JSON::null,
                            direction => 'backward',
                            end => JSON::null,
                            ended => JSON::false,
                            event => {
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
                            'source-credit' => '',
                            'target-credit' => '',
                            'target-type' => 'event',
                            type => 'parts',
                            'type-id' => '65742183-b25c-469e-b094-ff6739e6699c',
                        },
                    ],
                    setlist => '',
                    time => '',
                    type => 'Festival',
                    'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
                },
            ],
        };

    ws_test_json 'browse events via multiple events (invalid mbid)',
        '/event?event=3495abf6-4692-45cd-af62-7d964558676a&event=abc' =>
        {
            error => q(Invalid mbid 'abc'.),
            help => 'For usage, please see: https://musicbrainz.org/development/mmd',
        }, {response_code => HTTP_BAD_REQUEST};
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
