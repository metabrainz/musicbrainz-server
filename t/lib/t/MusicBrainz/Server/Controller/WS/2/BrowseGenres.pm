package t::MusicBrainz::Server::Controller::WS::2::BrowseGenres;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use HTTP::Status qw( :constants );

with 't::Mechanize', 't::Context';

use MusicBrainz::Server::Test::WS qw(
    ws2_test_xml
    ws2_test_xml_forbidden
    ws2_test_xml_unauthorized
);

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws2_test_xml 'browse genres via public collection',
    '/genre?collection=7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1a' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <genre-list count="1">
        <genre id="51cfaac4-6696-480b-8f1b-27cfc789109c">
            <name>grime</name>
            <disambiguation>stuff</disambiguation>
        </genre>
    </genre-list>
</metadata>';

ws2_test_xml 'browse genres via private collection',
    '/genre?collection=7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1b' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <genre-list count="1">
        <genre id="51cfaac4-6696-480b-8f1b-27cfc789109c">
            <name>grime</name>
            <disambiguation>stuff</disambiguation>
        </genre>
    </genre-list>
</metadata>',
    { username => 'the-anti-kuno', password => 'notreally' };

ws2_test_xml_forbidden 'browse genres via private collection, no credentials',
    '/genre?collection=7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1b';

ws2_test_xml_unauthorized 'browse genres via private collection, bad credentials',
    '/genre?collection=7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1b',
    { username => 'the-anti-kuno', password => 'idk' };

my $res = $test->mech->get('/ws/2/genre?collection=3c37b9fa-a6c1-37d2-9e90-657a116d337c&limit=-1');
is($res->code, HTTP_BAD_REQUEST);

$res = $test->mech->get('/ws/2/genre?collection=3c37b9fa-a6c1-37d2-9e90-657a116d337c&offset=a+bit');
is($res->code, HTTP_BAD_REQUEST);

$res = $test->mech->get('/ws/2/genre?collection=3c37b9fa-a6c1-37d2-9e90-657a116d337c&limit=10&offset=-1');
is($res->code, HTTP_BAD_REQUEST);

};

1;

