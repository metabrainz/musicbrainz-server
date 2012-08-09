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
            iswcs => [ "T-000.000.002-0" ],
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
                    iswcs => [ "T-000.000.002-0" ],
                }]
        });
};

1;
