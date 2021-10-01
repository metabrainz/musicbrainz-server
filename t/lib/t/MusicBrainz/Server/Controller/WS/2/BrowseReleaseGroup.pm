package t::MusicBrainz::Server::Controller::WS::2::BrowseReleaseGroup;
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

ws_test 'browse release group via release',
    '/release-group?release=adcf7b48-086e-48ee-b420-1001f88d672f&inc=artist-credits+tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group-list count="1">
        <release-group type="Album" type-id="f529b476-6e62-324f-b0aa-1f3e33d313fc" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
            <title>My Demons</title>
            <first-release-date>2007-01-29</first-release-date>
            <primary-type id="f529b476-6e62-324f-b0aa-1f3e33d313fc">Album</primary-type>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                        <name>Distance</name>
                        <sort-name>Distance</sort-name>
                        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
                        <rating votes-count="1">5</rating>
                    </artist>
                </name-credit>
            </artist-credit>
            <tag-list>
                <tag count="2"><name>dubstep</name></tag>
                <tag count="1"><name>electronic</name></tag>
                <tag count="1"><name>grime</name></tag>
            </tag-list>
            <rating votes-count="1">4</rating>
        </release-group>
    </release-group-list>
</metadata>';

ws_test 'browse release group via artist',
    '/release-group?artist=472bc127-8861-45e8-bc9e-31e8dd32de7a&inc=artist-credits+tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group-list count="2">
        <release-group type="Album" type-id="f529b476-6e62-324f-b0aa-1f3e33d313fc" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
            <title>My Demons</title>
            <first-release-date>2007-01-29</first-release-date>
            <primary-type id="f529b476-6e62-324f-b0aa-1f3e33d313fc">Album</primary-type>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                        <name>Distance</name>
                        <sort-name>Distance</sort-name>
                        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
                        <rating votes-count="1">5</rating>
                    </artist>
                </name-credit>
            </artist-credit>
            <tag-list>
                <tag count="2"><name>dubstep</name></tag>
                <tag count="1"><name>electronic</name></tag>
                <tag count="1"><name>grime</name></tag>
            </tag-list>
            <rating votes-count="1">4</rating>
        </release-group>
        <release-group type="Remix" type-id="0c60f497-ff81-3818-befd-abfc84a4858b" id="56683a0b-45b8-3664-a231-5b68efe2e7e2">
            <title>Repercussions</title>
            <first-release-date>2008-11-17</first-release-date>
            <primary-type id="f529b476-6e62-324f-b0aa-1f3e33d313fc">Album</primary-type>
            <secondary-type-list>
              <secondary-type id="0c60f497-ff81-3818-befd-abfc84a4858b">Remix</secondary-type>
            </secondary-type-list>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                        <name>Distance</name>
                        <sort-name>Distance</sort-name>
                        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
                        <rating votes-count="1">5</rating>
                    </artist>
                </name-credit>
            </artist-credit>
        </release-group>
    </release-group-list>
</metadata>';

ws_test 'browse singles via artist',
    '/release-group?artist=a16d1433-ba89-4f72-a47b-a370add0bb55&type=single' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group-list count="0" />
</metadata>';

};

1;

