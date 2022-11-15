package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseReleases;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'errors' => sub {

    use Test::JSON import => [ 'is_json' ];

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;
    $mech->default_header('Accept' => 'application/json');
    $mech->get('/ws/2/release?recording=7b1f6e95-b523-43b6-a048-810ea5d463a8');
    is($mech->status, 404, 'browse releases via non-existent recording');

    is_json($mech->content, encode_json({
          error => 'Not Found',
          help => 'For usage, please see: https://musicbrainz.org/development/mmd',
    }));
};

test 'browse releases via artist (paging)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via artist (paging)',
    '/release?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&offset=2' =>
        {
            'release-count' => 3,
            'release-offset' => 2,
            releases => [
                {
                    id => 'fbe4eb72-0f24-3875-942e-f581589713d4',
                    title => 'For Beginner Piano',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'eng', script => 'Latn' },
                    'cover-art-archive' => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => '1999-09-23',
                    country => 'US',
                    'release-events' => [{
                        date => '1999-09-23',
                        'area' => {
                            disambiguation => '',
                            'id' => '489ce91b-6658-3307-9877-795b68554c98',
                            'name' => 'United States',
                            'sort-name' => 'United States',
                            'iso-3166-1-codes' => ['US'],
                            'type' => JSON::null,
                            'type-id' => JSON::null,
                        },
                    }],
                    asin => 'B00001IVAI',
                    barcode => JSON::null,
                    disambiguation => '',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

test 'browse releases via label' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via label',
    '/release?inc=mediums&label=b4edce40-090f-4956-b82a-5d9d285da40b' =>
        {
            'release-count' => 2,
            'release-offset' => 0,
            releases => [
                {
                    id => '3b3d130a-87a8-4a47-b9fb-920f2530d134',
                    title => 'Repercussions',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'eng', script => 'Latn' },
                    'cover-art-archive' => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => '2008-11-17',
                    country => 'GB',
                    'release-events' => [{
                        date => '2008-11-17',
                        'area' => {
                            disambiguation => '',
                            'id' => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                            'name' => 'United Kingdom',
                            'sort-name' => 'United Kingdom',
                            'iso-3166-1-codes' => ['GB'],
                            'type' => JSON::null,
                            'type-id' => JSON::null,
                        },
                    }],
                    barcode => '600116822123',
                    media => [
                        {
                            format => 'CD',
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            position => 1,
                            'track-count' => 9,
                            title => '',
                        },
                        {
                            format => 'CD',
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            position => 2,
                            'track-count' => 9,
                            title => 'Chestplate Singles'
                        }],
                    asin => 'B001IKWNCE',
                    disambiguation => '',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                },
                {
                    id => 'adcf7b48-086e-48ee-b420-1001f88d672f',
                    title => 'My Demons',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'eng', script => 'Latn' },
                    'cover-art-archive' => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => '2007-01-29',
                    country => 'GB',
                    'release-events' => [{
                        date => '2007-01-29',
                        'area' => {
                            disambiguation => '',
                            'id' => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                            'name' => 'United Kingdom',
                            'sort-name' => 'United Kingdom',
                            'iso-3166-1-codes' => ['GB'],
                            'type' => JSON::null,
                            'type-id' => JSON::null,
                        },
                    }],
                    barcode => '600116817020',
                    media => [
                        {
                            format => 'CD',
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            position => 1,
                            'track-count' => 12,
                            title => '',
                        } ],
                    asin => 'B000KJTG6K',
                    disambiguation => '',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

test  'browse releases via release group' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via release group',
    '/release?release-group=b84625af-6229-305f-9f1b-59c0185df016' =>
        {
            'release-count' => 2,
            'release-offset' => 0,
            releases => [
                {
                    id => '0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e',
                    title => 'サマーれげぇ!レインボー',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'jpn', script => 'Jpan' },
                    'cover-art-archive' => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => '2001-07-04',
                    country => 'JP',
                    'release-events' => [{
                        date => '2001-07-04',
                        'area' => {
                            disambiguation => '',
                            'id' => '2db42837-c832-3c27-b4a3-08198f75693c',
                            'name' => 'Japan',
                            'sort-name' => 'Japan',
                            'iso-3166-1-codes' => ['JP'],
                            'type' => JSON::null,
                            'type-id' => JSON::null,
                        },
                    }],
                    barcode => '4942463511227',
                    asin => 'B00005LA6G',
                    disambiguation => '',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                },
                {
                    id => 'b3b7e934-445b-4c68-a097-730c6a6d47e6',
                    title => 'Summer Reggae! Rainbow',
                    status => 'Pseudo-Release',
                    'status-id' => '41121bb9-3413-3818-8a9a-9742318349aa',
                    quality => 'high',
                    'text-representation' => { language => 'jpn', script => 'Latn' },
                    'cover-art-archive' => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => '2001-07-04',
                    country => 'JP',
                    'release-events' => [{
                        date => '2001-07-04',
                        'area' => {
                            disambiguation => '',
                            'id' => '2db42837-c832-3c27-b4a3-08198f75693c',
                            'name' => 'Japan',
                            'sort-name' => 'Japan',
                            'iso-3166-1-codes' => ['JP'],
                            'type' => JSON::null,
                            'type-id' => JSON::null,
                        },
                    }],
                    barcode => '4942463511227',
                    asin => 'B00005LA6G',
                    disambiguation => '',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

test 'browse releases via recording, with recording rels' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via recording, with recording and work rels',
    '/release?inc=recordings+artist-rels+work-rels+recording-level-rels+work-level-rels&status=official&recording=c43ee188-0049-4eec-ba2e-0385c5edd2db' =>
        {
            'release-count' => 1,
            'release-offset' => 0,
            releases => [{
                asin => undef,
                barcode => '0208311348266',
                'cover-art-archive' => {
                    artwork => JSON::false,
                    back => JSON::false,
                    count => 0,
                    darkened => JSON::false,
                    front => JSON::false
                },
                disambiguation => '',
                id => 'ec0d0122-b559-4aa1-a017-7068814aae57',
                media => [ {
                    format => 'CD',
                    'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                    title => '',
                    'track-count' => 2,
                    'track-offset' => 0,
                    position => 1,
                    pregap => {
                        id => '1a0ba71b-fb23-3931-a426-cd204a82a90e',
                        title => 'Hello Goodbye [hidden track]',
                        length => 128000,
                        position => 0,
                        number => '0',
                        recording => {
                            id => 'c0beb80b-4185-4328-8761-b9e45a5d0ac6',
                            title => 'Hello Goodbye [hidden track]',
                            disambiguation => '',
                            length => 128000,
                            video => JSON::false,
                            relations => [{
                                begin => JSON::null,
                                attributes => [],
                                'attribute-ids' => {},
                                'attribute-values' => {},
                                type => 'performance',
                                direction => 'forward',
                                'type-id' => 'a3005666-a872-32c3-ad06-98af558e99b0',
                                ended => JSON::false,
                                'source-credit' => '',
                                'target-credit' => '',
                                end => JSON::null,
                                work => {
                                    id => 'c473ece7-4858-3f4f-9d7a-a1e026400888',
                                    attributes => [],
                                    iswcs => [],
                                    language => 'eng',
                                    languages => ['eng'],
                                    disambiguation => '',
                                    title => 'Hello Goodbye',
                                    'type' => JSON::null,
                                    'type-id' => JSON::null,
                                    relations => [{
                                        begin => JSON::null,
                                        attributes => [],
                                        'attribute-ids' => {},
                                        'attribute-values' => {},
                                        type => 'composer',
                                        direction => 'backward',
                                        'type-id' => 'd59d99ea-23d4-4a80-b066-edca32ee158f',
                                        ended => JSON::false,
                                        'source-credit' => '',
                                        'target-credit' => '',
                                        end => JSON::null,
                                        artist => {
                                            id => '38c5cdab-5d6d-43d1-85b0-dac41bde186e',
                                            'sort-name' => 'Blind Melon',
                                            disambiguation => '',
                                            name => 'Blind Melon',
                                            'type' => 'Group',
                                            'type-id' => 'e431f5f6-b5d2-343d-8b36-72607fffb74b',
                                        },
                                        'target-type' => 'artist',
                                    }],
                                },
                                'target-type' => 'work',
                            }],
                        }
                    },
                    tracks => [
                        {
                            id => '7b84af2d-96b3-3c50-a667-e7d10e8b000d',
                            title => 'Galaxie',
                            length => 211133,
                            position => 1,
                            number => '1',
                            recording => {
                                id => 'c43ee188-0049-4eec-ba2e-0385c5edd2db',
                                title => 'Hello Goodbye / Galaxie',
                                disambiguation => '',
                                length => 211133,
                                video => JSON::false,
                                relations => [{
                                    begin => JSON::null,
                                    attributes => ['guitar'],
                                    type => 'instrument',
                                    direction => 'backward',
                                    'type-id' => '59054b12-01ac-43ee-a618-285fd397e461',
                                    ended => JSON::false,
                                    'attribute-credits' => {'guitar' => 'crazy guitar'},
                                    'attribute-ids' => {'guitar' => '63021302-86cd-4aee-80df-2270d54f4978'},
                                    'attribute-values' => {},
                                    'source-credit' => '',
                                    'target-credit' => '',
                                    end => JSON::null,
                                    artist => {
                                        id => '05d83760-08b5-42bb-a8d7-00d80b3bf47c',
                                        'sort-name' => 'Allgood, Paul',
                                        disambiguation => '',
                                        name => 'Paul Allgood',
                                        'type' => 'Person',
                                        'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
                                    },
                                    'target-type' => 'artist',
                                }],
                            }
                        },
                        {
                            id => 'e9f7ca98-ba9d-3276-97a4-26475c9f4527',
                            title => '2 X 4',
                            length => 240400,
                            position => 2,
                            number => '2',
                            recording => {
                                id => 'c830c239-3f91-4485-9577-4b86f92ad725',
                                title => '2 X 4',
                                disambiguation => '',
                                length => 240400,
                                video => JSON::false,
                                relations => [],
                            }
                        }
                    ]
                } ],
                packaging => JSON::null,
                'packaging-id' => JSON::null,
                quality => 'normal',
                status => 'Official',
                'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                'text-representation' => {
                    language => 'eng',
                    script => 'Latn'
                },
                title => 'Soup',
                relations => [],
            }],
        };
};

test 'browse releases via track artist' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via track artist',
    '/release?track_artist=a16d1433-ba89-4f72-a47b-a370add0bb55' =>
        {
            'release-count' => 1,
            'release-offset' => 0,
            releases => [
                {
                    id => 'aff4a693-5970-4e2e-bd46-e2ee49c22de7',
                    title => 'the Love Bug',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'eng', script => 'Latn' },
                    'cover-art-archive' => {
                        artwork => JSON::true,
                        count => 1,
                        front => JSON::true,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => '2004-03-17',
                    country => 'JP',
                    'release-events' => [{
                        date => '2004-03-17',
                        'area' => {
                            disambiguation => '',
                            'id' => '2db42837-c832-3c27-b4a3-08198f75693c',
                            'name' => 'Japan',
                            'sort-name' => 'Japan',
                            'iso-3166-1-codes' => ['JP'],
                            'type' => JSON::null,
                            'type-id' => JSON::null,
                        },
                    }],
                    barcode => '4988064451180',
                    asin => 'B0001FAD2O',
                    disambiguation => '',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
