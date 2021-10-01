package t::MusicBrainz::Server::Controller::WS::2::LookupTagsRatings;
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

ws_test 'artist lookup with tags, genres and ratings',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=tags+genres+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name><sort-name>BoA</sort-name>
        <life-span>
            <begin>1986-11-05</begin>
        </life-span>
        <tag-list><tag count="1"><name>c-pop</name></tag><tag count="1"><name>j-pop</name></tag><tag count="1"><name>japanese</name></tag><tag count="1"><name>jpop</name></tag><tag count="1"><name>k-pop</name></tag><tag count="1"><name>kpop</name></tag><tag count="1"><name>pop</name></tag></tag-list>
        <genre-list><genre count="1" id="eba7715e-ee26-4989-8d49-9db382955419"><name>j-pop</name></genre><genre count="1" id="b74b3b6c-0700-46b1-aa55-1f2869a3bd1a"><name>k-pop</name></genre><genre count="1" id="911c7bbb-172d-4df8-9478-dbff4296e791"><name>pop</name></genre></genre-list>
        <rating votes-count="3">4.35</rating>
    </artist>
</metadata>';

ws_test 'artist lookup with tags, genres, user-tags, and user-genres',
    '/artist/1946a82a-f927-40c2-8235-38d64f50d043?inc=tags+genres+user-tags+user-genres' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Group" id="1946a82a-f927-40c2-8235-38d64f50d043" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
        <name>The Chemical Brothers</name>
        <sort-name>Chemical Brothers, The</sort-name>
        <life-span>
            <begin>1989</begin>
        </life-span>
        <tag-list>
            <tag count="3"><name>big beat</name></tag>
            <tag count="6"><name>british</name></tag>
            <tag count="1"><name>dance and electronica</name></tag>
            <tag count="7"><name>electronic</name></tag>
            <tag count="2"><name>electronica</name></tag>
            <tag count="1"><name>english</name></tag>
            <tag count="1"><name>house</name></tag>
            <tag count="1"><name>manchester</name></tag>
            <tag count="1"><name>trip-hop</name></tag>
            <tag count="1"><name>uk</name></tag>
            <tag count="1"><name>united kingdom</name></tag>
        </tag-list>
        <user-tag-list>
            <user-tag><name>big beat</name></user-tag>
            <user-tag><name>electronic</name></user-tag>
        </user-tag-list>
        <genre-list>
            <genre count="3" id="aac07ae0-8acf-4249-b5c0-2762b53947a2"><name>big beat</name></genre>
            <genre count="7" id="89255676-1f14-4dd8-bbad-fca839d6aff4"><name>electronic</name></genre>
            <genre count="2" id="53a3cea3-17af-4421-a07a-5824b540aeb5"><name>electronica</name></genre>
            <genre count="1" id="a2782cb6-1cd0-477c-a61d-b3f8b42dd1b3"><name>house</name></genre>
        </genre-list>
        <user-genre-list>
            <user-genre id="aac07ae0-8acf-4249-b5c0-2762b53947a2"><name>big beat</name></user-genre>
            <user-genre id="89255676-1f14-4dd8-bbad-fca839d6aff4"><name>electronic</name></user-genre>
        </user-genre-list>
    </artist>
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

ws_test 'recording lookup with tags and ratings',
    '/recording/7a356856-9483-42c2-bed9-dc07cb555952?inc=tags+genres+ratings' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="7a356856-9483-42c2-bed9-dc07cb555952">
        <title>Cella</title>
        <length>334000</length>
        <first-release-date>2007-01-29</first-release-date>
        <tag-list>
            <tag count="1">
                <name>dubstep</name>
            </tag>
        </tag-list>
        <genre-list>
            <genre count="1" id="1b50083b-1afa-4778-82c8-548b309af783">
                <name>dubstep</name>
            </genre>
        </genre-list>
    </recording>
</metadata>';

ws_test 'label lookup with tags, genres and ratings',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=tags+genres+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label type="Original Production" type-id="7aaa37fe-2def-3476-b359-80245850062d" id="b4edce40-090f-4956-b82a-5d9d285da40b">
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

ws_test 'release group lookup with tags, genres and ratings',
    '/release-group/22b54315-6e51-350b-bb34-e6e16f7688bd?inc=tags+genres+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Album" type-id="f529b476-6e62-324f-b0aa-1f3e33d313fc" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
        <title>My Demons</title>
        <first-release-date>2007-01-29</first-release-date>
        <primary-type id="f529b476-6e62-324f-b0aa-1f3e33d313fc">Album</primary-type>
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
        <genre-list>
            <genre count="2" id="1b50083b-1afa-4778-82c8-548b309af783">
                <name>dubstep</name>
            </genre>
            <genre count="1" id="89255676-1f14-4dd8-bbad-fca839d6aff4">
                <name>electronic</name>
            </genre>
            <genre count="1" id="51cfaac4-6696-480b-8f1b-27cfc789109c">
                <name>grime</name>
                <disambiguation>stuff</disambiguation>
            </genre>
        </genre-list>
        <rating votes-count="1">4</rating>
    </release-group>
</metadata>';

ws_test 'artist lookup with release-groups, tags, genres and ratings',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=release-groups+tags+genres+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name><sort-name>BoA</sort-name>
        <life-span>
            <begin>1986-11-05</begin>
        </life-span>
        <release-group-list count="1">
            <release-group type="Album" type-id="f529b476-6e62-324f-b0aa-1f3e33d313fc" id="23f421e7-431e-3e1d-bcbf-b91f5f7c5e2c">
            <title>LOVE &amp; HONESTY</title>
            <first-release-date>2004-01-15</first-release-date>
            <primary-type id="f529b476-6e62-324f-b0aa-1f3e33d313fc">Album</primary-type>
                <tag-list>
                    <tag count="1"><name>format-dvd-video</name></tag>
                </tag-list>
            </release-group>
        </release-group-list>
        <tag-list><tag count="1"><name>c-pop</name></tag><tag count="1"><name>j-pop</name></tag><tag count="1"><name>japanese</name></tag><tag count="1"><name>jpop</name></tag><tag count="1"><name>k-pop</name></tag><tag count="1"><name>kpop</name></tag><tag count="1"><name>pop</name></tag></tag-list>
        <genre-list><genre count="1" id="eba7715e-ee26-4989-8d49-9db382955419"><name>j-pop</name></genre><genre count="1" id="b74b3b6c-0700-46b1-aa55-1f2869a3bd1a"><name>k-pop</name></genre><genre count="1" id="911c7bbb-172d-4df8-9478-dbff4296e791"><name>pop</name></genre></genre-list>
        <rating votes-count="3">4.35</rating>
    </artist>
</metadata>';

ws_test 'release lookup with release-groups, tags, genres and ratings',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?inc=release-groups+tags+genres+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="adcf7b48-086e-48ee-b420-1001f88d672f">
                <title>My Demons</title>
                <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language>
                    <script>Latn</script>
                </text-representation>
        <release-group type="Album" type-id="f529b476-6e62-324f-b0aa-1f3e33d313fc" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
            <title>My Demons</title>
            <first-release-date>2007-01-29</first-release-date>
            <primary-type id="f529b476-6e62-324f-b0aa-1f3e33d313fc">Album</primary-type>
            <tag-list><tag count="2"><name>dubstep</name></tag><tag count="1"><name>electronic</name></tag><tag count="1"><name>grime</name></tag></tag-list>
            <genre-list><genre count="2" id="1b50083b-1afa-4778-82c8-548b309af783"><name>dubstep</name></genre><genre count="1" id="89255676-1f14-4dd8-bbad-fca839d6aff4"><name>electronic</name></genre><genre count="1" id="51cfaac4-6696-480b-8f1b-27cfc789109c"><name>grime</name><disambiguation>stuff</disambiguation></genre></genre-list>
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

