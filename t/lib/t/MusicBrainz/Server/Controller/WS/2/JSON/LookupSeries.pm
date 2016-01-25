package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupSeries;

use JSON;
use Test::Routine;
use Test::More;
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
            id => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
        };

    ws_test_json 'series lookup, inc=aliases',
        '/series/d977f7fd-96c9-4e3e-83b5-eb484a9e6582?inc=aliases' =>
        {
            disambiguation => '',
            name => 'Bach-Werke-Verzeichnis',
            type => 'Catalogue',
            id => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
            aliases => [
                {
                    primary => JSON::null,
                    type => JSON::null,
                    'sort-name' => 'BWV',
                    name => 'BWV',
                    locale => JSON::null,
                }
            ],
        };

    ws_test_json 'series lookup, inc=work-rels',
        '/series/d977f7fd-96c9-4e3e-83b5-eb484a9e6582?inc=work-rels' =>
        {
            disambiguation => '',
            name => 'Bach-Werke-Verzeichnis',
            type => 'Catalogue',
            id => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
            relations => [
                {
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
                        title => "Kantate, BWV 1 \"Wie sch\x{f6}n leuchtet der Morgenstern\"",
                        type => JSON::null,
                    },
                    'target-type' => 'work',
                },
                {
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
                        title => 'Kantate, BWV 2 "Ach Gott, vom Himmel sieh darein"',
                        type => JSON::null,
                    },
                    'target-type' => 'work',
                },
                {
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
                        title => 'Kantate, BWV 3 "Ach Gott, wie manches Herzeleid"',
                        type => JSON::null,
                    },
                    'target-type' => 'work',
                },
            ],
        };
};
