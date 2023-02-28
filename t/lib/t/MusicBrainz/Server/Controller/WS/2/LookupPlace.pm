package t::MusicBrainz::Server::Controller::WS::2::LookupPlace;
use utf8;
use strict;
use warnings;

use Test::Routine;

with 't::Mechanize', 't::Context';

use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

ws_test 'basic place lookup',
    '/place/df9269dd-0470-4ea2-97e8-c11e46080edd' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <place type="Venue" type-id="cd92781a-a73f-30e8-a430-55d7521338db" id="df9269dd-0470-4ea2-97e8-c11e46080edd">
        <name>A Test Place</name>
        <disambiguation>A PLACE!</disambiguation>
        <address>An Address</address>
        <coordinates>
            <latitude>0.323</latitude>
            <longitude>1.234</longitude>
        </coordinates>
        <area id="89a675c2-3e37-3518-b83c-418bad59a85a">
            <name>Europe</name>
            <sort-name>Europe</sort-name>
            <iso-3166-1-code-list>
                <iso-3166-1-code>XE</iso-3166-1-code>
            </iso-3166-1-code-list>
        </area>
        <life-span>
            <begin>2013</begin>
        </life-span>
    </place>
</metadata>';

ws_test 'place lookup, inc=aliases',
    '/place/df9269dd-0470-4ea2-97e8-c11e46080edd?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <place type="Venue" type-id="cd92781a-a73f-30e8-a430-55d7521338db" id="df9269dd-0470-4ea2-97e8-c11e46080edd">
        <name>A Test Place</name>
        <disambiguation>A PLACE!</disambiguation>
        <address>An Address</address>
        <coordinates>
            <latitude>0.323</latitude>
            <longitude>1.234</longitude>
        </coordinates>
        <area id="89a675c2-3e37-3518-b83c-418bad59a85a">
            <name>Europe</name>
            <sort-name>Europe</sort-name>
            <iso-3166-1-code-list>
                <iso-3166-1-code>XE</iso-3166-1-code>
            </iso-3166-1-code-list>
        </area>
        <life-span>
            <begin>2013</begin>
        </life-span>
        <alias-list count="1">
            <alias sort-name="A Test Place Alias">A Test Place Alias</alias>
        </alias-list>
    </place>
</metadata>';

ws_test 'place lookup, inc=annotation',
    '/place/df9269dd-0470-4ea2-97e8-c11e46080edd?inc=annotation' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <place type="Venue" type-id="cd92781a-a73f-30e8-a430-55d7521338db" id="df9269dd-0470-4ea2-97e8-c11e46080edd">
        <name>A Test Place</name>
        <disambiguation>A PLACE!</disambiguation>
        <address>An Address</address>
        <coordinates>
            <latitude>0.323</latitude>
            <longitude>1.234</longitude>
        </coordinates>
        <annotation>
            <text>this is a place annotation</text>
        </annotation>
        <area id="89a675c2-3e37-3518-b83c-418bad59a85a">
            <name>Europe</name>
            <sort-name>Europe</sort-name>
            <iso-3166-1-code-list>
                <iso-3166-1-code>XE</iso-3166-1-code>
            </iso-3166-1-code-list>
        </area>
        <life-span>
            <begin>2013</begin>
        </life-span>
    </place>
</metadata>';

};

1;

