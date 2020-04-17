package t::MusicBrainz::Server::Controller::WS::2::LookupReleaseGroup;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

ws_test 'basic release group lookup',
    '/release-group/b84625af-6229-305f-9f1b-59c0185df016' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Single" type-id="d6038452-8ee0-3f68-affc-2de9a1ede0b9" id="b84625af-6229-305f-9f1b-59c0185df016">
        <title>サマーれげぇ!レインボー</title>
        <first-release-date>2001-07-04</first-release-date>
        <primary-type id="d6038452-8ee0-3f68-affc-2de9a1ede0b9">Single</primary-type>
    </release-group>
</metadata>';

ws_test 'release group lookup, inc=annotation',
    '/release-group/22b54315-6e51-350b-bb34-e6e16f7688bd?inc=annotation' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Album" type-id="f529b476-6e62-324f-b0aa-1f3e33d313fc" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
        <title>My Demons</title>
        <annotation><text>this is a release group annotation</text></annotation>
        <first-release-date>2007-01-29</first-release-date>
        <primary-type id="f529b476-6e62-324f-b0aa-1f3e33d313fc">Album</primary-type>
    </release-group>
</metadata>';

ws_test 'release group lookup with releases',
    '/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2?inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Remix" type-id="0c60f497-ff81-3818-befd-abfc84a4858b" id="56683a0b-45b8-3664-a231-5b68efe2e7e2">
        <title>Repercussions</title>
        <first-release-date>2008-11-17</first-release-date>
        <primary-type id="f529b476-6e62-324f-b0aa-1f3e33d313fc">Album</primary-type>
        <secondary-type-list>
          <secondary-type id="0c60f497-ff81-3818-befd-abfc84a4858b">Remix</secondary-type>
        </secondary-type-list>
        <release-list count="1">
            <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134">
                <title>Repercussions</title>
                <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language>
                    <script>Latn</script>
                </text-representation>
                <date>2008-11-17</date>
                <country>GB</country>
                <release-event-list count="1">
                    <release-event>
                        <date>2008-11-17</date>
                        <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
                            <name>United Kingdom</name>
                            <sort-name>United Kingdom</sort-name>
                            <iso-3166-1-code-list>
                                <iso-3166-1-code>GB</iso-3166-1-code>
                            </iso-3166-1-code-list>
                        </area>
                    </release-event>
                </release-event-list>
                <barcode>600116822123</barcode>
            </release>
        </release-list>
    </release-group>
</metadata>';

ws_test 'release group lookup with artists',
    '/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2?inc=artists' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
    <release-group type="Single" type-id="d6038452-8ee0-3f68-affc-2de9a1ede0b9" id="153f0a09-fead-3370-9b17-379ebd09446b">
        <title>the Love Bug</title>
        <first-release-date>2004-03-17</first-release-date>
        <primary-type id="d6038452-8ee0-3f68-affc-2de9a1ede0b9">Single</primary-type>
        <artist-credit>
            <name-credit>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                    <rating votes-count="3">3</rating>
                </artist>
            </name-credit>
        </artist-credit>
        <release-list count="1">
            <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
                <title>the Love Bug</title>
                <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2004-03-17</date>
                <country>JP</country>
                <release-event-list count="1">
                    <release-event>
                        <date>2004-03-17</date>
                        <area id="2db42837-c832-3c27-b4a3-08198f75693c">
                           <name>Japan</name>
                           <sort-name>Japan</sort-name>
                            <iso-3166-1-code-list>
                                <iso-3166-1-code>JP</iso-3166-1-code>
                            </iso-3166-1-code-list>
                        </area>
                    </release-event>
                </release-event-list>
                <barcode>4988064451180</barcode>
            </release>
        </release-list>
        <rating votes-count="2">5</rating>
    </release-group>
</metadata>';

ws_test 'release group lookup with pseudo-releases',
    '/release-group/153f0a09-fead-3370-9b17-379ebd09446b?inc=artists+releases&status=pseudo-release' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Single" type-id="d6038452-8ee0-3f68-affc-2de9a1ede0b9" id="153f0a09-fead-3370-9b17-379ebd09446b">
        <title>the Love Bug</title>
        <first-release-date>2004-03-17</first-release-date>
        <primary-type id="d6038452-8ee0-3f68-affc-2de9a1ede0b9">Single</primary-type>
        <artist-credit>
            <name-credit>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </name-credit>
        </artist-credit>
        <release-list count="0" />
    </release-group>
</metadata>';

};

1;

