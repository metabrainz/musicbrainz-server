package t::MusicBrainz::Server::Controller::WS::js::Work;
use Test::More;
use Test::Routine;
use JSON;
use MusicBrainz::Server::Test;
use Test::JSON import => [ 'is_valid_json' ];

with 't::Mechanize', 't::Context';

test all => sub {

    my $test = shift;
    my $c = $test->c;
    my $json = JSON::Any->new( utf8 => 1 );

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    $c->sql->do(<<'EOSQL');
INSERT INTO work_alias (work, name, sort_name, locale, primary_for_locale)
    VALUES (4223060, 'Hello! Let''s Meet Again (7ninmatsuri version)', 'Hello! Let''s Meet Again (7ninmatsuri version)', 'en', FALSE),
           (4223060, 'Hello! Let''s Meet Again (7ninmatsuri version)', 'Hello! Let''s Meet Again (7ninmatsuri version)', 'en_US', TRUE),
           (4223060, 'Saluton! Ni Renkontu Denove (7nin-matsuria versio)', 'Saluton! Ni Renkontu Denove (7nin-matsuria versio)', 'eo', TRUE);
EOSQL

    my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header("Accept" => "application/json");

    my $url = '/ws/js/work?q=Let\'s Meet Again&direct=true';

    $mech->get_ok($url, 'fetching');
    is_valid_json ($mech->content, "validating (is_valid_json)");

    my $data = $json->decode($mech->content);

    is($data->[0]->{id}, 4223060, 'Got the work expected');
    is($data->[0]->{primary_alias}, 'Hello! Let\'s Meet Again (7ninmatsuri version)', 'Got correct primary alias (en_US)');

    $c->sql->do(<<'EOSQL');
INSERT INTO work_alias (work, name, sort_name, locale, primary_for_locale)
    VALUES (4223060, 'Hello! Let''s Meet Again (7nin Matsuri version)', 'Hello! Let''s Meet Again (7nin Matsuri version)', 'en', TRUE);
EOSQL

    $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header("Accept" => "application/json");
    $mech->get_ok($url, 'fetching again');
    is_valid_json ($mech->content, "validating (is_valid_json)");

    $data = $json->decode($mech->content);

    is($data->[0]->{id}, 4223060, 'Got the work expected');
    is($data->[0]->{primary_alias}, 'Hello! Let\'s Meet Again (7nin Matsuri version)', 'Got correct primary alias (en)');

};

1;
