package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupURL;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test::WS qw(
    ws2_test_json
    ws2_test_json_not_found
);

with 't::Mechanize', 't::Context';

test 'basic url lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws2_test_json 'basic url lookup',
    '/url/e0a79771-e9f0-4127-b58a-f5e6869c8e96' =>
      { id => 'e0a79771-e9f0-4127-b58a-f5e6869c8e96',
        resource => 'http://www.discogs.com/artist/Paul+Allgood',
      };

    ws2_test_json 'basic url lookup (by URL)',
    '/url?resource=http://www.discogs.com/artist/Paul%2BAllgood' =>
      { id => 'e0a79771-e9f0-4127-b58a-f5e6869c8e96',
        resource => 'http://www.discogs.com/artist/Paul+Allgood',
      };

    ws2_test_json 'multiple url lookup (by URL, with inc=artist-rels+release-rels)',
        '/url?resource=http://www.discogs.com/artist/Paul%2BAllgood' .
            '&resource=http://www.discogs.com/release/30896' .
            '&inc=artist-rels+release-rels' => {
        'url-count' => 2,
        'url-offset' => 0,
        urls => [
            {
                id => '9bd7cece-05e3-438b-a2a1-070f8a829ed5',
                relations => [
                    {
                        'attribute-ids' => {},
                        'attribute-values' => {},
                        attributes => [],
                        begin => JSON::null,
                        direction => 'backward',
                        end => JSON::null,
                        ended => JSON::false,
                        release => {
                            barcode => '5021603064126',
                            country => 'GB',
                            date => '1999-09-13',
                            disambiguation => '',
                            id => '4f5a6b97-a09b-4893-80d1-eae1f3bfa221',
                            packaging => JSON::null,
                            'packaging-id' => JSON::null,
                            quality => 'normal',
                            'release-events' => [
                                {
                                    area => {
                                        disambiguation => '',
                                        id => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                                        'iso-3166-1-codes' => [
                                            'GB',
                                        ],
                                        name => 'United Kingdom',
                                        'sort-name' => 'United Kingdom',
                                        type => JSON::null,
                                        'type-id' => JSON::null,
                                    },
                                    date => '1999-09-13',
                                },
                            ],
                            status => JSON::null,
                            'status-id' => JSON::null,
                            'text-representation' => {
                                language => 'eng',
                                script => 'Latn',
                            },
                            title => 'For Beginner Piano',
                        },
                        'source-credit' => '',
                        'target-credit' => '',
                        'target-type' => 'release',
                        type => 'discogs',
                        'type-id' => '4a78823c-1c53-4176-a5f3-58026c76f2bc',
                    },
                    {
                        'attribute-ids' => {},
                        'attribute-values' => {},
                        attributes => [],
                        begin => JSON::null,
                        direction => 'backward',
                        end => JSON::null,
                        ended => JSON::false,
                        release => {
                            barcode => JSON::null,
                            country => 'US',
                            date => '1999-09-23',
                            disambiguation => '',
                            id => 'fbe4eb72-0f24-3875-942e-f581589713d4',
                            packaging => JSON::null,
                            'packaging-id' => JSON::null,
                            quality => 'normal',
                            'release-events' => [
                                {
                                    area => {
                                        disambiguation => '',
                                        id => '489ce91b-6658-3307-9877-795b68554c98',
                                        'iso-3166-1-codes' => [
                                            'US',
                                        ],
                                        name => 'United States',
                                        'sort-name' => 'United States',
                                        type => JSON::null,
                                        'type-id' => JSON::null,
                                    },
                                    date => '1999-09-23',
                                },
                            ],
                            status => JSON::null,
                            'status-id' => JSON::null,
                            'text-representation' => {
                                language => 'eng',
                                script => 'Latn',
                            },
                            title => 'For Beginner Piano',
                        },
                        'source-credit' => '',
                        'target-credit' => '',
                        'target-type' => 'release',
                        type => 'discogs',
                        'type-id' => '4a78823c-1c53-4176-a5f3-58026c76f2bc',
                    },
                    {
                        'attribute-ids' => {},
                        'attribute-values' => {},
                        attributes => [],
                        begin => JSON::null,
                        direction => 'backward',
                        end => JSON::null,
                        ended => JSON::false,
                        release => {
                            barcode => '',
                            country => 'GB',
                            date => '1999-09-13',
                            disambiguation => '',
                            id => 'dd66bfdd-6097-32e3-91b6-67f47ba25d4c',
                            packaging => JSON::null,
                            'packaging-id' => JSON::null,
                            quality => 'normal',
                            'release-events' => [
                                {
                                    area => {
                                        disambiguation => '',
                                        id => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                                        'iso-3166-1-codes' => [
                                            'GB',
                                        ],
                                        name => 'United Kingdom',
                                        'sort-name' => 'United Kingdom',
                                        type => JSON::null,
                                        'type-id' => JSON::null,
                                    },
                                    date => '1999-09-13',
                                },
                            ],
                            status => JSON::null,
                            'status-id' => JSON::null,
                            'text-representation' => {
                                language => 'eng',
                                script => 'Latn',
                            },
                            title => 'For Beginner Piano',
                        },
                        'source-credit' => '',
                        'target-credit' => '',
                        'target-type' => 'release',
                        type => 'discogs',
                        'type-id' => '4a78823c-1c53-4176-a5f3-58026c76f2bc',
                    },
                ],
                resource => 'http://www.discogs.com/release/30896',
            },
            {
                id => 'e0a79771-e9f0-4127-b58a-f5e6869c8e96',
                relations => [
                    {
                        artist => {
                            disambiguation => '',
                            id => '05d83760-08b5-42bb-a8d7-00d80b3bf47c',
                            name => 'Paul Allgood',
                            'sort-name' => 'Allgood, Paul',
                            type => 'Person',
                            'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
                        },
                        'attribute-ids' => {},
                        'attribute-values' => {},
                        attributes => [],
                        begin => JSON::null,
                        direction => 'backward',
                        end => JSON::null,
                        ended => JSON::false,
                        'source-credit' => '',
                        'target-credit' => '',
                        'target-type' => 'artist',
                        type => 'discogs',
                        'type-id' => '04a5b104-a4c2-4bac-99a1-7b837c37d9e4',
                    },
                ],
                resource => 'http://www.discogs.com/artist/Paul+Allgood',
            },
        ],
    };

    ws2_test_json_not_found 'basic url lookup (by URL, 404)',
        '/url?resource=http://www.disscog.com/artist/Paul%2BAllgood';

    ws2_test_json 'multiple url lookup (by URL, none found)',
        '/url?resource=http://www.disscog.com/artist/Paul%2BAllgood' .
            '&resource=http://www.disscog.com/release/30896' .
            '&inc=artist-rels+release-rels' => {
        'url-count' => 0,
        'url-offset' => 0,
        urls => [],
    };

    ws2_test_json 'basic url lookup (with inc=artist-rels)',
    '/url/e0a79771-e9f0-4127-b58a-f5e6869c8e96?inc=artist-rels' =>
        {
            id => 'e0a79771-e9f0-4127-b58a-f5e6869c8e96',
            resource => 'http://www.discogs.com/artist/Paul+Allgood',
            relations => [
                {
                    attributes => [],
                    'attribute-ids' => {},
                    'attribute-values' => {},
                    direction => 'backward',
                    artist => {
                        id => '05d83760-08b5-42bb-a8d7-00d80b3bf47c',
                        name => 'Paul Allgood',
                        'sort-name' => 'Allgood, Paul',
                        disambiguation => '',
                        'type' => 'Person',
                        'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
                    },
                    ended => JSON::false,
                    begin => JSON::null,
                    type => 'discogs',
                    'type-id' => '04a5b104-a4c2-4bac-99a1-7b837c37d9e4',
                    end => JSON::null,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'artist',
                }],
        };
};

1;
