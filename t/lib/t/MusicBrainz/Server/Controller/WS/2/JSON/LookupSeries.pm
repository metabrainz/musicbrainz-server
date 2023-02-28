package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupSeries;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic series lookup' => sub {
    my $c = shift->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws_test_json 'basic series lookup',
        '/series/d977f7fd-96c9-4e3e-83b5-eb484a9e6582' => {
            disambiguation => '',
            name => 'Bach-Werke-Verzeichnis',
            type => 'Catalogue',
            'type-id' => '49482ff0-fc9e-3b8c-a2d0-30e84d9df002',
            id => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
        };

    ws_test_json 'series lookup, inc=aliases',
        '/series/d977f7fd-96c9-4e3e-83b5-eb484a9e6582?inc=aliases' =>
        {
            disambiguation => '',
            name => 'Bach-Werke-Verzeichnis',
            type => 'Catalogue',
            'type-id' => '49482ff0-fc9e-3b8c-a2d0-30e84d9df002',
            id => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
            aliases => [
                {
                    primary => JSON::null,
                    type => JSON::null,
                    'type-id' => JSON::null,
                    'sort-name' => 'BWV',
                    name => 'BWV',
                    locale => JSON::null,
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                }
            ],
        };

    ws_test_json 'series lookup, inc=work-rels',
        '/series/d977f7fd-96c9-4e3e-83b5-eb484a9e6582?inc=work-rels' =>
        {
            disambiguation => '',
            name => 'Bach-Werke-Verzeichnis',
            type => 'Catalogue',
            'type-id' => '49482ff0-fc9e-3b8c-a2d0-30e84d9df002',
            id => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
            relations => [
                {
                    'attribute-ids' => {number => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'},
                    'attribute-values' => {number => 'BWV 1'},
                    attributes => ['number'],
                    begin => JSON::null,
                    direction => 'forward',
                    end => JSON::null,
                    ended => JSON::false,
                    'ordering-key' => 1,
                    'source-credit' => '',
                    'target-credit' => '',
                    type => 'part of',
                    'type-id' => 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
                    work => {
                        attributes => [],
                        disambiguation => '',
                        id => '13bb5d97-00db-4fd8-920c-14da7c11bdd4',
                        iswcs => [],
                        language => 'deu',
                        languages => ['deu'],
                        title => qq(Kantate, BWV 1 "Wie sch\x{f6}n leuchtet der Morgenstern"),
                        type => 'Cantata',
                        'type-id' => '0db2f555-15f9-393f-af4c-739db5711146',
                    },
                    'target-type' => 'work',
                },
                {
                    'attribute-ids' => {number => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'},
                    'attribute-values' => {number => 'BWV 2'},
                    attributes => ['number'],
                    begin => JSON::null,
                    direction => 'forward',
                    end => JSON::null,
                    ended => JSON::false,
                    'ordering-key' => 2,
                    'source-credit' => '',
                    'target-credit' => '',
                    type => 'part of',
                    'type-id' => 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
                    work => {
                        attributes => [],
                        disambiguation => '',
                        id => 'fa97639c-ea29-47d6-9461-16b411322bac',
                        iswcs => [],
                        language => 'deu',
                        languages => ['deu'],
                        title => 'Kantate, BWV 2 "Ach Gott, vom Himmel sieh darein"',
                        type => 'Cantata',
                        'type-id' => '0db2f555-15f9-393f-af4c-739db5711146',
                    },
                    'target-type' => 'work',
                },
                {
                    'attribute-ids' => {number => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'},
                    'attribute-values' => {number => 'BWV 3'},
                    attributes => ['number'],
                    begin => JSON::null,
                    direction => 'forward',
                    end => JSON::null,
                    ended => JSON::false,
                    'ordering-key' => 3,
                    'source-credit' => '',
                    'target-credit' => '',
                    type => 'part of',
                    'type-id' => 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
                    work => {
                        attributes => [],
                        disambiguation => '',
                        id => '3edf4a3f-2b11-4a61-a5cf-e193363ef55c',
                        iswcs => [],
                        language => 'deu',
                        languages => ['deu'],
                        title => 'Kantate, BWV 3 "Ach Gott, wie manches Herzeleid"',
                        type => 'Cantata',
                        'type-id' => '0db2f555-15f9-393f-af4c-739db5711146',
                    },
                    'target-type' => 'work',
                },
            ],
        };
};
