package t::MusicBrainz::Server::Controller::WS::1::LookupRelease;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use HTTP::Request::Common;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 1
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca');
EOSQL

MusicBrainz::Server::Test->prepare_raw_test_database(
    $c, <<'EOSQL');
TRUNCATE release_group_tag_raw CASCADE;
TRUNCATE release_group_rating_raw CASCADE;

INSERT INTO release_group_tag_raw (release_group, editor, tag)
    VALUES (377462, 1, 114);

INSERT INTO release_group_rating_raw (release_group, editor, rating)
    VALUES (377462, 1, 100);
EOSQL

ws_test 'release',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
    <title>My Demons</title><text-representation script="Latn" language="ENG" />
    <asin>B000KJTG6K</asin>
  </release>
</metadata>';

ws_test 'release with artist (single artist)',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=artist' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
    <title>My Demons</title><text-representation script="Latn" language="ENG" />
    <asin>B000KJTG6K</asin>
    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
      <sort-name>Distance</sort-name><name>Distance</name>
    </artist>
  </release>
</metadata>';

ws_test 'release with artist (multiple artists)',
    '/release/91c1799c-fb3a-4e06-9cca-c78a6a5092c0?type=xml&inc=artist' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="91c1799c-fb3a-4e06-9cca-c78a6a5092c0" type="Single Official">
    <title>Desert Siege / Crash</title><text-representation script="Latn" language="ENG" />
    <artist id="02e55d3a-f7c3-4ddc-a4aa-a7938f99c81c">
      <sort-name>Chris.Su &amp; SKC</sort-name><name>Chris.Su &amp; SKC</name>
    </artist>
  </release>
</metadata>';

ws_test 'release with tags',
    '/release/0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
    <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" /><asin>B00005LA6G</asin>
    <tag-list>
      <tag count="1">hello project</tag>
    </tag-list>
  </release>
</metadata>';

ws_test 'release with release-groups',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=release-groups' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
    <title>My Demons</title><text-representation script="Latn" language="ENG" /><asin>B000KJTG6K</asin>
    <release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd" type="Album">
      <title>My Demons</title>
    </release-group>
  </release>
</metadata>';

ws_test 'release with tracks (single medium)',
    '/release/91c1799c-fb3a-4e06-9cca-c78a6a5092c0?type=xml&inc=tracks' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="91c1799c-fb3a-4e06-9cca-c78a6a5092c0" type="Single Official">
    <title>Desert Siege / Crash</title><text-representation script="Latn" language="ENG" />
    <track-list>
      <track id="933fc27f-aa4c-4a6f-a354-ababd8e99ea2"><title>Desert Siege</title></track>
      <track id="8ab8590d-ad87-4e55-afa9-41e46eff666f"><title>Crash</title></track>
    </track-list>
  </release>
</metadata>';

ws_test 'release with tracks & artists (single medium, no VA)',
    '/release/91c1799c-fb3a-4e06-9cca-c78a6a5092c0?type=xml&inc=tracks+artist' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="91c1799c-fb3a-4e06-9cca-c78a6a5092c0" type="Single Official">
    <title>Desert Siege / Crash</title><text-representation script="Latn" language="ENG" />
    <track-list>
      <track id="933fc27f-aa4c-4a6f-a354-ababd8e99ea2"><title>Desert Siege</title></track>
      <track id="8ab8590d-ad87-4e55-afa9-41e46eff666f"><title>Crash</title></track>
    </track-list>
    <artist id="02e55d3a-f7c3-4ddc-a4aa-a7938f99c81c">
      <sort-name>Chris.Su &amp; SKC</sort-name><name>Chris.Su &amp; SKC</name>
    </artist>
  </release>
</metadata>';

ws_test 'release with tracks & artists (single medium, VA release)',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?type=xml&inc=tracks+artist' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7" type="Single Official">
    <title>the Love Bug</title><text-representation script="Latn" language="ENG" /><asin>B0001FAD2O</asin>
    <track-list>
      <track id="0cf3008f-e246-428f-abc1-35f87d584d60">
        <title>the Love Bug</title>
        <duration>243000</duration>
        <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
          <sort-name>m-flo♥BoA</sort-name><name>m-flo♥BoA</name>
        </artist>
      </track>
      <track id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
        <title>the Love Bug (Big Bug NYC remix)</title>
        <duration>222000</duration>
        <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
          <sort-name>m-flo♥BoA</sort-name><name>m-flo♥BoA</name>
        </artist>
      </track>
      <track id="3f33fc37-43d0-44dc-bfd6-60efd38810c5">
        <title>the Love Bug (cover)</title>
        <duration>333000</duration>
        <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
          <sort-name>BAGDAD CAFE THE trench town</sort-name><name>BAGDAD CAFE THE trench town</name>
        </artist>
      </track>
    </track-list>
    <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
      <sort-name>m-flo</sort-name><name>m-flo</name>
    </artist>
  </release>
</metadata>';

ws_test 'release with release events',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=release-events' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
    <title>My Demons</title><text-representation script="Latn" language="ENG" /><asin>B000KJTG6K</asin>
    <release-event-list>
      <event date="2007-01-29" format="CD" barcode="600116817020" catalog-number="ZIQ170CD" country="GB" />
    </release-event-list>
  </release>
</metadata>';

ws_test 'release with release events & labels',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=release-events+labels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
    <title>My Demons</title><text-representation script="Latn" language="ENG" /><asin>B000KJTG6K</asin>
    <release-event-list>
      <event date="2007-01-29" format="CD" barcode="600116817020" catalog-number="ZIQ170CD" country="GB">
        <label id="b4edce40-090f-4956-b82a-5d9d285da40b">
          <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
          <life-span begin="1995" />
        </label>
      </event>
    </release-event-list>
  </release>
</metadata>';

ws_test 'release with isrcs',
    '/release/0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e?type=xml&inc=tracks+isrcs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
<release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
  <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" /><asin>B00005LA6G</asin>
  <track-list>
    <track id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
      <title>サマーれげぇ!レインボー</title><duration>296026</duration>
      <isrc-list><isrc id="JPA600102450" /></isrc-list>
    </track>
    <track id="487cac92-eed5-4efa-8563-c9a818079b9a">
      <title>HELLO! また会おうね (7人祭 version)</title><duration>213106</duration>
      <isrc-list><isrc id="JPA600102460" /></isrc-list>
    </track>
    <track id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
      <title>サマーれげぇ!レインボー (instrumental)</title><duration>292800</duration>
      <isrc-list><isrc id="JPA600102459" /></isrc-list>
    </track>
  </track-list>
</release></metadata>';

ws_test 'release with puids',
    '/release/0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e?type=xml&inc=tracks+puids' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official"><title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" /><asin>B00005LA6G</asin><track-list><track id="162630d9-36d2-4a8d-ade1-1c77440b34e7"><title>サマーれげぇ!レインボー</title><duration>296026</duration><puid-list><puid id="cdec3fe2-0473-073c-3cbb-bfb0c01a87ff" /></puid-list></track><track id="487cac92-eed5-4efa-8563-c9a818079b9a"><title>HELLO! また会おうね (7人祭 version)</title><duration>213106</duration><puid-list><puid id="251bd265-84c7-ed8f-aecf-1d9918582399" /></puid-list></track><track id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e"><title>サマーれげぇ!レインボー (instrumental)</title><duration>292800</duration><puid-list><puid id="7b8a868f-1e67-852b-5141-ad1edfb1e492" /></puid-list></track></track-list></release></metadata>';

ws_test 'release with ratings',
    '/release/699c8545-75b4-378e-bc29-9d0f951f7eee?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><release id="699c8545-75b4-378e-bc29-9d0f951f7eee" type="Album Official"><title>Surrender</title><text-representation script="Latn" language="ENG" /><rating votes-count="3">4</rating></release></metadata>';

ws_test 'release with artist-relationships',
    '/release/4f5a6b97-a09b-4893-80d1-eae1f3bfa221?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221" type="Album Official"><title>For Beginner Piano</title><text-representation script="Latn" language="ENG" /><asin>B00001IVAI</asin><relation-list target-type="Artist"><relation direction="backward" target="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Design/Illustration"><artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4"><name>Plone</name><sort-name>Plone</sort-name></artist></relation></relation-list></release></metadata>';

ws_test 'release with url-relationships',
    '/release/4f5a6b97-a09b-4893-80d1-eae1f3bfa221?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221" type="Album Official">
    <title>For Beginner Piano</title><text-representation script="Latn" language="ENG" /><asin>B00001IVAI</asin>
    <relation-list target-type="Url">
      <relation target="http://www.amazon.com/gp/product/B00001IVAI" type="AmazonAsin" />
      <relation target="http://www.discogs.com/release/1722" type="Discogs" />
      <relation target="http://www.discogs.com/release/30895" type="Discogs" />
      <relation target="http://www.discogs.com/release/30896" type="Discogs" />
    </relation-list>
  </release>
</metadata>';

ws_test 'release with release-relationships',
    '/release/757a1723-3769-4298-89cd-48d31177852a?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="757a1723-3769-4298-89cd-48d31177852a" type="Album Pseudo-Release">
    <title>LOVE &amp; HONESTY</title><text-representation script="Latn" language="JPN" /><asin>B0000YGBSG</asin>
    <relation-list target-type="Release">
      <relation direction="backward" target="28fc2337-985b-3da9-ac40-ad6f28ff0d8e" type="Transl-Tracklisting" attributes="Transliterated">
        <release id="28fc2337-985b-3da9-ac40-ad6f28ff0d8e" type="Album Official">
          <title>LOVE &amp; HONESTY</title><text-representation script="Jpan" language="JPN" />
          <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55"><name>BoA</name><sort-name>BoA</sort-name></artist>
        </release>
      </relation>
      <relation direction="backward" target="cacc586f-c2f2-49db-8534-6f44b55196f2" type="Transl-Tracklisting" attributes="Transliterated">
        <release id="cacc586f-c2f2-49db-8534-6f44b55196f2" type="Album Official">
          <title>LOVE &amp; HONESTY</title><text-representation script="Jpan" language="JPN" />
          <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55"><name>BoA</name><sort-name>BoA</sort-name></artist>
        </release>
      </relation>
    </relation-list>
  </release>
</metadata>';

ws_test 'release with counts',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=counts' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
    <title>My Demons</title><text-representation script="Latn" language="ENG" /><asin>B000KJTG6K</asin>
    <release-event-list count="1" /><disc-list count="1" /><track-list count="12" />
  </release>
</metadata>';

ws_test 'release with discs',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=discs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
    <title>My Demons</title><text-representation script="Latn" language="ENG" /><asin>B000KJTG6K</asin>
    <disc-list>
      <disc id="75S7Yp3IiqPVREQhjAjMXPhwz0Y-" sectors="281289" />
    </disc-list>
  </release>
</metadata>';

ws_test 'release with label-relationships',
    '/release/f07d489d-a06e-4f39-b95e-5692e2a4f465?type=xml&inc=label-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
 <release id="f07d489d-a06e-4f39-b95e-5692e2a4f465" type="Album Official">
 <title>Recipe for Hate</title>
 <text-representation script="Latn" language="ENG" />
 <asin>B000002IX5</asin>
 <relation-list target-type="Label">
  <relation direction="backward"
            target="1bfd06be-a6ed-4ced-8159-7d4d2923a40c"
            type="Publishing">
   <label id="1bfd06be-a6ed-4ced-8159-7d4d2923a40c">
    <name>Epitaph</name>
    <sort-name>Epitaph</sort-name>
    <life-span begin="1980" />
   </label>
  </relation>
  <relation direction="backward"
            target="50c384a2-0b44-401b-b893-8181173339c7"
            type="Publishing">
   <label id="50c384a2-0b44-401b-b893-8181173339c7">
    <name>Atlantic</name>
    <sort-name>Atlantic</sort-name>
    <label-code>121</label-code><life-span begin="1947" />
   </label>
  </relation>
 </relation-list>
</release></metadata>';

ws_test 'release with track-relationships',
    '/release/4ccb3e54-caab-4ad4-94a6-a598e0e52eec?type=xml&inc=track-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
<release id="4ccb3e54-caab-4ad4-94a6-a598e0e52eec" type="Spokenword Official">
 <title>An Inextricable Tale Audiobook</title>
 <text-representation script="Latn" language="ENG" />
 <asin>B000XULO2A</asin>
 <relation-list target-type="Track">
  <relation direction="backward"
            target="37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9"
            begin="2008"
            type="SamplesMaterial">
   <track id="37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9">
    <title>Dear Diary</title>
    <duration>86666</duration>
    <artist id="6fe9f838-112e-44f1-af83-97464f08285b"><name>Wedlock</name><sort-name>Wedlock</sort-name></artist>
   </track>
  </relation>
 </relation-list>
</release></metadata>';

ws_test 'release with user tags',
    '/release/0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
    <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" /><asin>B00005LA6G</asin>
    <user-tag-list>
      <user-tag>hello project</user-tag>
    </user-tag-list>
  </release>
</metadata>',
    { username => 'editor', password => 'password' };

ws_test 'release with user ratings',
    '/release/0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
 <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
  <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" /><asin>B00005LA6G</asin>
  <user-rating>5</user-rating>
 </release>
</metadata>',
    { username => 'editor', password => 'password' };

{
local $TODO = 'Todo';

ws_test 'release with track-level-relationships',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=track-level-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';
};

};

1;

