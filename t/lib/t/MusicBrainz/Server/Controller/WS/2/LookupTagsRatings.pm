package t::MusicBrainz::Server::Controller::WS::2::LookupTagsRatings;
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

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'artist lookup with tags and ratings',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name><sort-name>BoA</sort-name>
        <life-span>
            <begin>1986-11-05</begin>
        </life-span>
        <tag-list><tag count="1"><name>c-pop</name></tag><tag count="1"><name>j-pop</name></tag><tag count="1"><name>japanese</name></tag><tag count="1"><name>jpop</name></tag><tag count="1"><name>k-pop</name></tag><tag count="1"><name>kpop</name></tag><tag count="1"><name>pop</name></tag></tag-list>
        <rating votes-count="3">4.35</rating>
    </artist>
</metadata>';

ws_test 'recording lookup with tags and ratings',
    '/recording/7a356856-9483-42c2-bed9-dc07cb555952?inc=tags+ratings' =>
    '<?xml version="1.0"?><metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#"><recording id="7a356856-9483-42c2-bed9-dc07cb555952"><title>Cella</title><length>334000</length><tag-list><tag count="1"><name>dubstep</name></tag></tag-list></recording></metadata>';

ws_test 'label lookup with tags and ratings',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label type="Original Production" id="b4edce40-090f-4956-b82a-5d9d285da40b">
        <name>Planet Mu</name>
        <sort-name>Planet Mu</sort-name>
        <country>GB</country>
        <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
            <name>United Kingdom</name>
            <sort-name>United Kingdom</sort-name>
            <iso-3166-1-code-list>
                <iso-3166-1-code>GB</iso-3166-1-code>
            </iso-3166-1-code-list>
        </area>
        <life-span>
            <begin>1995</begin>
        </life-span>
        <tag-list>
            <tag count="1"><name>british</name></tag>
            <tag count="1"><name>english</name></tag>
            <tag count="1"><name>uk</name></tag>
        </tag-list>
    </label>
</metadata>';

ws_test 'release group lookup with tags and ratings',
    '/release-group/22b54315-6e51-350b-bb34-e6e16f7688bd?inc=tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Album" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
        <title>My Demons</title>
        <first-release-date>2007-01-29</first-release-date>
        <primary-type>Album</primary-type>
        <tag-list>
            <tag count="2">
                <name>dubstep</name>
            </tag>
            <tag count="1">
                <name>electronic</name>
            </tag>
            <tag count="1">
                <name>grime</name>
            </tag>
        </tag-list>
        <rating votes-count="1">4</rating>
    </release-group>
</metadata>';

ws_test 'artist lookup with release-groups, tags and ratings',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=release-groups+tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name><sort-name>BoA</sort-name>
        <life-span>
            <begin>1986-11-05</begin>
        </life-span>
        <release-group-list count="1">
            <release-group type="Album" id="23f421e7-431e-3e1d-bcbf-b91f5f7c5e2c">
            <title>LOVE &amp; HONESTY</title>
            <first-release-date>2004-01-15</first-release-date>
            <primary-type>Album</primary-type>
                <tag-list>
                    <tag count="1"><name>format-dvd-video</name></tag>
                </tag-list>
            </release-group>
        </release-group-list>
        <tag-list><tag count="1"><name>c-pop</name></tag><tag count="1"><name>j-pop</name></tag><tag count="1"><name>japanese</name></tag><tag count="1"><name>jpop</name></tag><tag count="1"><name>k-pop</name></tag><tag count="1"><name>kpop</name></tag><tag count="1"><name>pop</name></tag></tag-list>
        <rating votes-count="3">4.35</rating>
    </artist>
</metadata>';

ws_test 'release lookup with release-groups, tags and ratings',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?inc=release-groups+tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="adcf7b48-086e-48ee-b420-1001f88d672f">
                <title>My Demons</title>
                <status>Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language>
                    <script>Latn</script>
                </text-representation>
        <release-group type="Album" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
            <title>My Demons</title>
            <first-release-date>2007-01-29</first-release-date>
            <primary-type>Album</primary-type>
            <tag-list><tag count="2"><name>dubstep</name></tag><tag count="1"><name>electronic</name></tag><tag count="1"><name>grime</name></tag></tag-list>
            <rating votes-count="1">4</rating>
        </release-group>
	<date>2007-01-29</date>
	<country>GB</country>
    	<release-event-list count="1">
	    <release-event>
    		<date>2007-01-29</date>
	    	<area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
		    <name>United Kingdom</name>
	            <sort-name>United Kingdom</sort-name>
		    <iso-3166-1-code-list>
	    		<iso-3166-1-code>GB</iso-3166-1-code>
	   	    </iso-3166-1-code-list>
	        </area>
	    </release-event>
	</release-event-list>
	<barcode>600116817020</barcode>
        <asin>B000KJTG6K</asin>
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>';

};

1;

