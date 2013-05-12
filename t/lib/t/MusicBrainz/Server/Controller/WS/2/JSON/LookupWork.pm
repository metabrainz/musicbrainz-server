package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupWork;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic work lookup' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, "
        INSERT INTO iswc (work, iswc)
        VALUES ((SELECT id FROM work WHERE gid = '3c37b9fa-a6c1-37d2-9e90-657a116d337c'),
        'T-000.000.002-0');");

    ws_test_json 'basic work lookup',
    '/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c' => encode_json (
        {
            id => "3c37b9fa-a6c1-37d2-9e90-657a116d337c",
            title => "サマーれげぇ!レインボー",
            disambiguation => "",
            iswcs => [ "T-000.000.002-0" ],
            language => 'jpn',
            type => 'Song',
        });
};

test 'basic work lookup, inc=annotation' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

    ws_test_json 'basic work lookup, inc=annotation',
    '/work/482530c1-a2ab-32e8-be43-ea5240aa7913?inc=annotation' => encode_json (
        {
            id => "482530c1-a2ab-32e8-be43-ea5240aa7913",
            title => "Plock",
            disambiguation => "",
            annotation => "this is a work annotation",
            iswcs => [ ],
            language => JSON::null,
            type => JSON::null,
        });
};

test 'work lookup via iswc' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        "INSERT INTO iswc (work, iswc) VALUES (".
        "  (SELECT id FROM work WHERE gid = '3c37b9fa-a6c1-37d2-9e90-657a116d337c'), ".
        "  'T-000.000.002-0');");

    ws_test_json 'work lookup via iswc',
    '/iswc/T-000.000.002-0' => encode_json (
        {
            "work-count" => 1,
            "work-offset" => 0,
            works => [
                {
                    id => "3c37b9fa-a6c1-37d2-9e90-657a116d337c",
                    title => "サマーれげぇ!レインボー",
                    disambiguation => "",
                    iswcs => [ "T-000.000.002-0" ],
                    language => 'jpn',
                    type => "Song",
                }]
        });
};

test 'work lookup with recording relationships' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'work lookup with recording relationships',
    '/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c?inc=recording-rels' => encode_json (
        {
            id => "3c37b9fa-a6c1-37d2-9e90-657a116d337c",
            title => "サマーれげぇ!レインボー",
            disambiguation => "",
            relations => [
                {
                    attributes => [],
                    type => "performance",
                    'type-id' => 'fdc57134-e05c-30bc-aff6-425684475276',
                    direction => "backward",
                    recording => {
                        id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
                        title => "サマーれげぇ!レインボー",
                        length => 296026,
                        disambiguation => "",
                    },
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                },
                {
                    attributes => [],
                    type => "performance",
                    'type-id' => 'fdc57134-e05c-30bc-aff6-425684475276',
                    direction => "backward",
                    recording => {
                        id => "eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e",
                        title => "サマーれげぇ!レインボー (instrumental)",
                        length => 292800,
                        disambiguation => "",
                    },
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                }
                ],
            iswcs => [],
            language => 'jpn',
            type => "Song",
        });

};

1;
