package t::MusicBrainz::Server::Controller::WS::2::BrowseRecordings;
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use utf8;
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'browse recordings via artist (first page)',
    '/recording?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&limit=3' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list count="10">
        <recording id="7e379a1d-f2bc-47b8-964e-00723df34c8a">
            <title>Be Rude to Your School</title>
            <length>208706</length>
            <first-release-date>1999-09-13</first-release-date>
        </recording>
        <recording id="6f9c8c32-3aae-4dad-b023-56389361cf6b">
            <title>Bibi Plone</title>
            <length>173960</length>
            <first-release-date>1999-09-13</first-release-date>
        </recording>
        <recording id="4f392ffb-d3df-4f8a-ba74-fdecbb1be877">
            <title>Busy Working</title>
            <length>217440</length>
            <first-release-date>1999-09-13</first-release-date>
        </recording>
    </recording-list>
</metadata>';

ws_test 'browse recordings via artist (second page)',
    '/recording?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&limit=3&offset=3' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list count="10" offset="3">
        <recording id="791d9b27-ae1a-4295-8943-ded4284f2122">
            <title>Marbles</title>
            <length>229826</length>
            <first-release-date>1999-09-13</first-release-date>
        </recording>
        <recording id="44704dda-b877-4551-a2a8-c1f764476e65">
            <title>On My Bus</title>
            <length>267560</length>
            <first-release-date>1999-09-13</first-release-date>
        </recording>
        <recording id="6e89c516-b0b6-4735-a758-38e31855dcb6">
            <title>Plock</title>
            <length>237133</length>
            <first-release-date>1999-09-13</first-release-date>
        </recording>
    </recording-list>
</metadata>';

ws_test 'browse recordings via release',
    '/recording?release=adcf7b48-086e-48ee-b420-1001f88d672f&limit=4' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list count="12">
        <recording id="7a356856-9483-42c2-bed9-dc07cb555952">
            <title>Cella</title>
            <length>334000</length>
            <first-release-date>2007-01-29</first-release-date>
        </recording>
        <recording id="e5a5847b-451b-4051-a09b-8295329097e3">
            <title>Confined</title>
            <length>314000</length>
            <first-release-date>2007-01-29</first-release-date>
        </recording>
        <recording id="a4eb6323-519d-44e4-8ab7-df0a0f9df349">
            <title>Cyclops</title>
            <length>265000</length>
            <first-release-date>2007-01-29</first-release-date>
        </recording>
        <recording id="9011e90d-b7e3-400b-b932-305f94608772">
            <title>Delight</title>
            <length>339000</length>
            <first-release-date>2007-01-29</first-release-date>
        </recording>
    </recording-list>
</metadata>';

ws_test 'browse recordings via work',
    '/recording?work=f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8&limit=1' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list count="1">
        <recording id="4878bc36-7306-497a-b45a-561d9f7f8573">
            <title>Asseswaving</title>
            <length>274666</length>
            <first-release-date>2008-04-29</first-release-date>
        </recording>
    </recording-list>
</metadata>';

};

1;

