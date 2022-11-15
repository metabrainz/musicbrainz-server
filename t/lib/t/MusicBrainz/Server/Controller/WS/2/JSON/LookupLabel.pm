package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupLabel;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic label lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic label lookup',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b' =>
        {
            id => 'b4edce40-090f-4956-b82a-5d9d285da40b',
            name => 'Planet Mu',
            'sort-name' => 'Planet Mu',
            type => 'Original Production',
            'type-id' => '7aaa37fe-2def-3476-b359-80245850062d',
            disambiguation => '',
            'label-code' => JSON::null,
            country => 'GB',
            'life-span' => {
                begin => '1995',
                end => JSON::null,
                ended => JSON::false,
            },
            'area' => {
                disambiguation => '',
                'id' => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                'name' => 'United Kingdom',
                'sort-name' => 'United Kingdom',
                'iso-3166-1-codes' => ['GB'],
                'type' => JSON::null,
                'type-id' => JSON::null,
            },
            ipis => [],
            isnis => [],
        };
};

test 'basic label lookup, inc=annotation' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

    ws_test_json 'basic label lookup, inc=annotation',
    '/label/46f0f4cd-8aab-4b33-b698-f459faf64190?inc=annotation' =>
        {
            id => '46f0f4cd-8aab-4b33-b698-f459faf64190',
            name => 'Warp Records',
            'sort-name' => 'Warp Records',
            type => 'Original Production',
            'type-id' => '7aaa37fe-2def-3476-b359-80245850062d',
            annotation => 'this is a label annotation',
            disambiguation => '',
            'label-code' => 2070,
            country => 'GB',
            'life-span' => {
                begin => '1989',
                end => JSON::null,
                ended => JSON::false,
            },
            'area' => {
                disambiguation => '',
                'id' => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                'name' => 'United Kingdom',
                'sort-name' => 'United Kingdom',
                'iso-3166-1-codes' => ['GB'],
                'type' => JSON::null,
                'type-id' => JSON::null,
            },
            ipis => [],
            isnis => [],
        };
};

test 'label lookup, inc=aliases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'label lookup, inc=aliases',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=aliases' =>
        {
            id => 'b4edce40-090f-4956-b82a-5d9d285da40b',
            name => 'Planet Mu',
            'sort-name' => 'Planet Mu',
            type => 'Original Production',
            'type-id' => '7aaa37fe-2def-3476-b359-80245850062d',
            disambiguation => '',
            'label-code' => JSON::null,
            country => 'GB',
            'life-span' => {
                begin => '1995',
                end => JSON::null,
                ended => JSON::false,
            },
            'area' => {
                disambiguation => '',
                'id'  => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                'name' => 'United Kingdom',
                'sort-name' => 'United Kingdom',
                'iso-3166-1-codes' => ['GB'],
                'type' => JSON::null,
                'type-id' => JSON::null,
            },
            aliases => [
                {
                    name => 'Planet µ',
                    'sort-name' => 'Planet µ',
                    locale => JSON::null,
                    primary => JSON::null,
                    type => JSON::null,
                    'type-id' => JSON::null,
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                }
            ],
            ipis => [],
            isnis => [],
        };
};

test 'label lookup with releases, inc=media' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'label lookup with releases, inc=media',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=releases+media' =>
        {
            id => 'b4edce40-090f-4956-b82a-5d9d285da40b',
            name => 'Planet Mu',
            'sort-name' => 'Planet Mu',
            type => 'Original Production',
            'type-id' => '7aaa37fe-2def-3476-b359-80245850062d',
            disambiguation => '',
            'label-code' => JSON::null,
            country => 'GB',
            'life-span' => {
                begin => '1995',
                end => JSON::null,
                ended => JSON::false,
            },
            'area' => {
                disambiguation => '',
                'id' => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                'name' => 'United Kingdom',
                'sort-name' => 'United Kingdom',
                'iso-3166-1-codes' => ['GB'],
                'type' => JSON::null,
                'type-id' => JSON::null,
            },
            releases => [
                {
                    id => 'adcf7b48-086e-48ee-b420-1001f88d672f',
                    title => 'My Demons',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'eng', script => 'Latn' },
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
                    disambiguation => '',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                    media => [
                        {
                            format => 'CD',
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            'track-count' => 12,
                            position => 1,
                            title => '',
                        } ]
                },
                {
                    id => '3b3d130a-87a8-4a47-b9fb-920f2530d134',
                    title => 'Repercussions',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'eng', script => 'Latn' },
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
                    disambiguation => '',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                    media => [
                        {
                            format => 'CD',
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            'track-count' => 9,
                            position => 1,
                            title => '',
                        },
                        {
                            format => 'CD',
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            'track-count' => 9,
                            position => 2,
                            title => 'Chestplate Singles'
                        },
                    ],
                },
            ],
            ipis => [],
            isnis => [],
        };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
