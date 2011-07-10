package t::MusicBrainz::Server::Controller::WS::2::LookupReleaseGroup;
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

ws_test 'basic release group lookup',
    '/release-group/b84625af-6229-305f-9f1b-59c0185df016' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Single" id="b84625af-6229-305f-9f1b-59c0185df016" first-release-date="2001-07-04">
        <title>サマーれげぇ!レインボー</title>
    </release-group>
</metadata>';

ws_test 'release group lookup with releases',
    '/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2?inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Album" id="56683a0b-45b8-3664-a231-5b68efe2e7e2" first-release-date="2008-11-17">
        <title>Repercussions</title>
        <release-list count="1">
            <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134">
                <title>Repercussions</title><status>Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2008-11-17</date><country>GB</country>
                <barcode>600116822123</barcode>
            </release>
        </release-list>
    </release-group>
</metadata>';

ws_test 'release group lookup with artists',
    '/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2?inc=artists' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Album" id="56683a0b-45b8-3664-a231-5b68efe2e7e2" first-release-date="2008-11-17">
        <title>Repercussions</title>
        <artist-credit>
            <name-credit>
                <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                    <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
                </artist>
            </name-credit>
        </artist-credit>
    </release-group>
</metadata>';

ws_test 'release group lookup with inc=artists+releases+tags+ratings',
    '/release-group/153f0a09-fead-3370-9b17-379ebd09446b?inc=artists+releases+tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Single" id="153f0a09-fead-3370-9b17-379ebd09446b" first-release-date="2004-03-17">
        <title>the Love Bug</title>
        <artist-credit>
            <name-credit>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                    <rating votes-count="3">3</rating>
                </artist>
            </name-credit>
        </artist-credit>
        <release-list count="1">
            <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
                <title>the Love Bug</title><status>Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
            </release>
        </release-list>
    </release-group>
</metadata>';

ws_test 'release group lookup with pseudo-releases',
    '/release-group/153f0a09-fead-3370-9b17-379ebd09446b?inc=artists+releases&status=pseudo-release' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Single" id="153f0a09-fead-3370-9b17-379ebd09446b" first-release-date="2004-03-17">
        <title>the Love Bug</title>
        <artist-credit>
            <name-credit>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </name-credit>
        </artist-credit>
        <release-list count="0" />
    </release-group>
</metadata>';

};

1;

