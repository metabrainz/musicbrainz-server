package t::MusicBrainz::Server::Controller::WS::1::Search;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

use FindBin qw($Bin);
use LWP;
use LWP::UserAgent::Mockable;

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Request::Common;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 1
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c);

LWP::UserAgent::Mockable->reset('playback', $Bin.'/ws-1-search.lwp-mock');

ws_test 'search for artists by name',
    '/artist/?type=xml&name=Distance',
    '<?xml version="1.0" standalone="yes"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist-list offset="0" count="43">
        <artist type="Person" id="781f23eb-0249-457f-8d9b-cae0c83dc36f" ext:score="100" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>Esa Ruoho - Now known as lackluster</disambiguation>
        </artist>
        <artist type="Unknown" id="f8b7ae84-6975-4937-bb46-071290c59061" ext:score="100" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>House/Trance artist</disambiguation>
        </artist>
        <artist type="Group" id="7e58c2d7-362c-43f7-b008-53f1a27bd64f" ext:score="100" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>Hard Rock</disambiguation>
        </artist>
        <artist type="Group" id="0dc6cbf9-2f0e-47a4-a397-776c5d3746a1" ext:score="100" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>Piano Rock, Brighton Band</disambiguation>
        </artist>
        <artist type="Person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a" ext:score="100" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        </artist>
        <artist type="Unknown" id="80f6758f-1cbb-4d26-8d11-95ff78b0f0fc" ext:score="100" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>Dark Electro Group</disambiguation>
        </artist>
        <artist type="Unknown" id="6c8ca38c-d0fd-413f-8877-db2b8ede75b7" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Critical Distance</name><sort-name>Critical Distance</sort-name>
        </artist>
        <artist type="Unknown" id="8efe5445-999a-4853-9a63-d097cfa97cdc" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance Formula</name><sort-name>Distance Formula</sort-name>
        </artist>
        <artist type="Unknown" id="de957070-0f50-417f-a4b0-7fa262fa678f" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Striking Distance</name><sort-name>Striking Distance</sort-name>
        </artist>
        <artist type="Group" id="9013874f-4c4f-4d07-99e4-393f08583b97" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>The Distance</name><sort-name>Distance, The</sort-name>
        </artist>
        <artist type="Unknown" id="67295a28-e3ae-4b97-84a9-b34ee867e1fc" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Natural Distance</name><sort-name>Natural Distance</sort-name>
        </artist>
        <artist type="Group" id="da4f4b31-3824-42bf-ab04-bc02ec82f04b" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Longue Distance</name><sort-name>Longue Distance</sort-name>
        </artist>
        <artist type="Person" id="c5f8f7ff-9587-41ff-8d26-294a4ad93cc3" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance Alone</name><sort-name>Distance Alone</sort-name>
        </artist>
        <artist type="Person" id="a9f73bff-605d-4b27-8f46-94f6384712f0" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Long Distance</name><sort-name>Long Distance</sort-name>
        </artist>
        <artist type="Group" id="661fab43-f6b8-4e39-840f-ab1d002259ed" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance Delay</name><sort-name>Distance Delay</sort-name>
        </artist>
        <artist type="Person" id="2087d712-7bc2-4d10-8be2-2a26984a6a4a" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Fast Distance</name><sort-name>Fast Distance</sort-name>
        </artist>
        <artist type="Unknown" id="76fdea64-fdbc-48c9-b2ee-538c2b7a5b46" ext:score="62" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Love Distance</name><sort-name>Love Distance</sort-name>
        </artist>
        <artist type="Unknown" id="528ef1e5-5b6f-466b-bb83-33ad21f4909f" ext:score="50" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance and Materials</name><sort-name>Distance and Materials</sort-name>
        </artist>
        <artist type="Group" id="29c41ff5-9700-418c-9c7b-104991ba4634" ext:score="50" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>In the Distance</name><sort-name>In the Distance</sort-name>
        </artist>
        <artist type="Unknown" id="8606abe2-3c52-472c-89ec-0daa2d2c07c0" ext:score="50" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Time and Distance</name><sort-name>Time and Distance</sort-name>
        </artist>
        <artist type="Group" id="07d0d3be-d419-4e21-9063-293d8b63840a" ext:score="50" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Long Distance Runner</name><sort-name>Long Distance Runner</sort-name>
        </artist>
        <artist type="Unknown" id="0a170661-4966-4eb3-a6fd-a577f37c23e0" ext:score="50" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance From Afar</name><sort-name>Distance From Afar</sort-name>
        </artist>
        <artist type="Unknown" id="b4ce1d92-bb2c-491d-8a6f-1f05176e5bae" ext:score="50" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Distance In Embrace</name><sort-name>Distance In Embrace</sort-name>
        </artist>
        <artist type="Unknown" id="3756cca3-3688-49a4-b0c9-af6cd5efdab8" ext:score="50" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Long Distance Call Blues</name><sort-name>Long Distance Call Blues</sort-name>
        </artist>
        <artist type="Group" id="9df9b90e-53ec-458e-954a-69650cbe84eb" ext:score="50" xmlns:ext="http://musicbrainz.org/ns/ext#-1.0">
            <name>Long Distance Calling</name><sort-name>Long Distance Calling</sort-name>
        </artist>
    </artist-list>
</metadata>';

LWP::UserAgent::Mockable->finished;

};

1;

