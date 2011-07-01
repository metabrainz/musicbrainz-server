package t::MusicBrainz::Server::Controller::WS::2::BrowseReleaseGroup;
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

ws_test 'browse release group via release',
    '/release-group?release=adcf7b48-086e-48ee-b420-1001f88d672f&inc=artist-credits+tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group-list count="1">
        <release-group type="Album" id="22b54315-6e51-350b-bb34-e6e16f7688bd" first-release-date="2007-01-29">
            <title>My Demons</title>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                        <name>Distance</name>
                        <sort-name>Distance</sort-name>
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
        <release-group type="Album" id="22b54315-6e51-350b-bb34-e6e16f7688bd" first-release-date="2007-01-29">
            <title>My Demons</title>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                        <name>Distance</name>
                        <sort-name>Distance</sort-name>
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
        <release-group type="Album" id="56683a0b-45b8-3664-a231-5b68efe2e7e2" first-release-date="2008-11-17">
            <title>Repercussions</title>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                        <name>Distance</name>
                        <sort-name>Distance</sort-name>
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

