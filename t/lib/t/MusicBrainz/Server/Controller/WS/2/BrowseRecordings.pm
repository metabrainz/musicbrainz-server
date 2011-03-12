package t::MusicBrainz::Server::Controller::WS::2::BrowseRecordings;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use XML::SemanticDiff;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $v2 = schema_validator;
my $diff = XML::SemanticDiff->new;
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'browse recordings via artist (first page)',
    '/recording?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&inc=puids&limit=3' => 
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list count="10">
        <recording id="4f392ffb-d3df-4f8a-ba74-fdecbb1be877">
            <title>Busy Working</title><length>217440</length>
            <puid-list count="1">
                <puid id="1d8cf2de-4e31-2043-cbb2-9d61d000e5da" />
            </puid-list>
        </recording>
        <recording id="6f9c8c32-3aae-4dad-b023-56389361cf6b">
            <title>Bibi Plone</title><length>173960</length>
            <puid-list count="1">
                <puid id="a1f6892c-8cf4-150f-3e42-2d32c7652460" />
            </puid-list>
        </recording>
        <recording id="7e379a1d-f2bc-47b8-964e-00723df34c8a">
            <title>Be Rude to Your School</title><length>208706</length>
            <puid-list count="2">
                <puid id="24dd0c12-3f22-955d-f35e-d3d8867eee8d" />
                <puid id="7038d263-9736-015b-e43d-4e6e7bb85138" />
            </puid-list>
        </recording>
    </recording-list>
</metadata>';

ws_test 'browse recordings via artist (second page)',
    '/recording?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&inc=puids&limit=3&offset=3' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list count="10" offset="3">
        <recording id="44704dda-b877-4551-a2a8-c1f764476e65">
            <title>On My Bus</title><length>267560</length>
            <puid-list count="2">
                <puid id="138f0487-85eb-5fe9-355d-9b94a60ff1dc" />
                <puid id="59963809-99c6-86c8-246a-85c1779bed07" />
            </puid-list>
        </recording>
        <recording id="6e89c516-b0b6-4735-a758-38e31855dcb6">
            <title>Plock</title><length>237133</length>
            <puid-list count="2">
                <puid id="138f0487-85eb-5fe9-355d-9b94a60ff1dc" />
                <puid id="e21f9f94-85cd-5e40-d158-0cea7e4b5877" />
            </puid-list>
        </recording>
        <recording id="791d9b27-ae1a-4295-8943-ded4284f2122">
            <title>Marbles</title><length>229826</length>
            <puid-list count="2">
                <puid id="45aa205f-1fdb-b441-a97b-17d95c786cc0" />
                <puid id="53760233-32b0-09f6-131d-5f796ffd4b52" />
            </puid-list>
        </recording>
    </recording-list>
</metadata>';

ws_test 'browse recordings via release',
    '/recording?release=adcf7b48-086e-48ee-b420-1001f88d672f&limit=4' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list count="12">
        <recording id="7a356856-9483-42c2-bed9-dc07cb555952">
            <title>Cella</title><length>334000</length>
        </recording>
        <recording id="9011e90d-b7e3-400b-b932-305f94608772">
            <title>Delight</title><length>339000</length>
        </recording>
        <recording id="a4eb6323-519d-44e4-8ab7-df0a0f9df349">
            <title>Cyclops</title><length>265000</length>
        </recording>
        <recording id="e5a5847b-451b-4051-a09b-8295329097e3">
            <title>Confined</title><length>314000</length>
        </recording>
    </recording-list>
</metadata>';

};

1;

