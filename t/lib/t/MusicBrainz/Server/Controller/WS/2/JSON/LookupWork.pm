package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupWork;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic work lookup' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO iswc (work, iswc)
            VALUES ((SELECT id FROM work WHERE gid = '3c37b9fa-a6c1-37d2-9e90-657a116d337c'),
                    'T-000.000.002-0')
        SQL

    ws_test_json 'basic work lookup',
    '/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c' =>
        {
            attributes => [],
            id => '3c37b9fa-a6c1-37d2-9e90-657a116d337c',
            title => 'サマーれげぇ!レインボー',
            disambiguation => '',
            iswcs => [ 'T-000.000.002-0' ],
            language => 'jpn',
            languages => ['jpn'],
            type => 'Song',
            'type-id' => 'f061270a-2fd6-32f1-a641-f0f8676d14e6',
        };
};

test 'basic work lookup, inc=annotation' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

    ws_test_json 'basic work lookup, inc=annotation',
    '/work/482530c1-a2ab-32e8-be43-ea5240aa7913?inc=annotation' =>
        {
            attributes => [],
            id => '482530c1-a2ab-32e8-be43-ea5240aa7913',
            title => 'Plock',
            disambiguation => '',
            annotation => 'this is a work annotation',
            iswcs => [ ],
            language => JSON::null,
            languages => [],
            type => JSON::null,
            'type-id' => JSON::null,
        };
};

test 'work lookup via iswc' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO iswc (work, iswc)
            VALUES ((SELECT id FROM work WHERE gid = '3c37b9fa-a6c1-37d2-9e90-657a116d337c'),
                    'T-000.000.002-0')
        SQL

    ws_test_json 'work lookup via iswc',
    '/iswc/T-000.000.002-0' =>
        {
            'work-count' => 1,
            'work-offset' => 0,
            works => [
                {
                    attributes => [],
                    id => '3c37b9fa-a6c1-37d2-9e90-657a116d337c',
                    title => 'サマーれげぇ!レインボー',
                    disambiguation => '',
                    iswcs => [ 'T-000.000.002-0' ],
                    language => 'jpn',
                    languages => ['jpn'],
                    type => 'Song',
                    'type-id' => 'f061270a-2fd6-32f1-a641-f0f8676d14e6',
                }]
        };
};

test 'work lookup with recording relationships' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'work lookup with recording relationships',
    '/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c?inc=recording-rels' =>
        {
            attributes => [],
            id => '3c37b9fa-a6c1-37d2-9e90-657a116d337c',
            title => 'サマーれげぇ!レインボー',
            disambiguation => '',
            relations => [
                {
                    attributes => [],
                    'attribute-ids' => {},
                    'attribute-values' => {},
                    type => 'performance',
                    'type-id' => 'a3005666-a872-32c3-ad06-98af558e99b0',
                    direction => 'backward',
                    recording => {
                        id => '162630d9-36d2-4a8d-ade1-1c77440b34e7',
                        title => 'サマーれげぇ!レインボー',
                        length => 296026,
                        video => JSON::false,
                        disambiguation => '',
                    },
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'recording',
                },
                {
                    attributes => [],
                    'attribute-ids' => {},
                    'attribute-values' => {},
                    type => 'performance',
                    'type-id' => 'a3005666-a872-32c3-ad06-98af558e99b0',
                    direction => 'backward',
                    recording => {
                        id => 'eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e',
                        title => 'サマーれげぇ!レインボー (instrumental)',
                        length => 292800,
                        video => JSON::false,
                        disambiguation => '',
                    },
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                    'source-credit' => '',
                    'target-credit' => '',
                    'target-type' => 'recording',
                }
            ],
            iswcs => [],
            language => 'jpn',
            languages => ['jpn'],
            type => 'Song',
            'type-id' => 'f061270a-2fd6-32f1-a641-f0f8676d14e6',
        };
};

test 'work lookup with multiple languages' => sub {
    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+multi_language_work');

    ws_test_json 'work lookup with recording relationships',
    '/work/8753a51f-dd84-492d-8c5a-a39283045118' =>
        {
            attributes => [],
            id => '8753a51f-dd84-492d-8c5a-a39283045118',
            title => 'Mon petit amoureux',
            disambiguation => '',
            iswcs => [],
            language => 'mul',
            languages => ['eng', 'fra'],
            type => 'Song',
            'type-id' => 'f061270a-2fd6-32f1-a641-f0f8676d14e6',
        };
};

1;
