use utf8;
use strict;
use Test::More;

use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

ws_test 'lookup track',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <track id="c869cc03-cb88-462b-974e-8e46c1538ad4">
    <title>Rock With You</title><duration>255146</duration>
  </track>
</metadata>';

ws_test 'lookup track with a single artist',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=artist' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <track id="c869cc03-cb88-462b-974e-8e46c1538ad4">
    <title>Rock With You</title><duration>255146</duration>
    <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
      <sort-name>BoA</sort-name><name>BoA</name>
    </artist>
  </track>
</metadata>';

ws_test 'lookup track with multiple artists',
    '/track/84c98ebf-5d40-4a29-b7b2-0e9c26d9061d?type=xml&inc=artist' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <track id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
    <title>the Love Bug (Big Bug NYC remix)</title><duration>222000</duration>
    <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
      <sort-name>m-flo♥BoA</sort-name><name>m-flo♥BoA</name>
    </artist>
  </track>
</metadata>';

ws_test 'lookup track with tags',
    '/track/eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <track id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
    <title>サマーれげぇ!レインボー (instrumental)</title><duration>292800</duration>
    <tag-list>
      <tag count="1">instrumental version</tag><tag count="1">jpop</tag><tag count="1">korean</tag>
      <tag count="1">metal</tag><tag count="1">thrash metal</tag>
    </tag-list>
  </track>
</metadata>';

ws_test 'lookup track with isrcs',
    '/track/162630d9-36d2-4a8d-ade1-1c77440b34e7?type=xml&inc=isrcs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <track id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
    <title>サマーれげぇ!レインボー</title><duration>296026</duration>
    <isrc-list><isrc id="JPA600102450" /></isrc-list>
  </track>
</metadata>';

ws_test 'lookup track with puids',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=puids' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <track id="c869cc03-cb88-462b-974e-8e46c1538ad4">
    <title>Rock With You</title><duration>255146</duration>
    <puid-list><puid id="242d65cb-3cd2-517c-f0a7-5d05413cf4c9" />
      <puid id="acaef019-b6dd-ba4f-75ab-31a055b68859" />
    </puid-list>
  </track>
</metadata>';

ws_test 'lookup track with releases',
    '/track/162630d9-36d2-4a8d-ade1-1c77440b34e7?type=xml&inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <track id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
    <title>サマーれげぇ!レインボー</title><duration>296026</duration>
    <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
      <sort-name>7nin Matsuri</sort-name><name>7人祭</name>
    </artist>
    <release-list>
      <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6" type="Single Pseudo-Release">
        <title>Summer Reggae! Rainbow</title><text-representation script="Latn" language="JPN" />
      </release>
      <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
        <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" />
      </release>
    </release-list>
  </track>
</metadata>';

ws_test 'lookup track with artist-relationships',
    '/track/0cf3008f-e246-428f-abc1-35f87d584d60?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="0cf3008f-e246-428f-abc1-35f87d584d60">
 <title>the Love Bug</title>
 <duration>242226</duration>
 <relation-list target-type="Artist">
  <relation direction="backward"
            target="22dd2db3-88ea-4428-a7a8-5cd3acf23175"
            type="Programming">
   <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
    <name>m-flo</name>
    <sort-name>m-flo</sort-name>
    <life-span begin="1998" />
   </artist>
  </relation>
  <relation direction="backward"
            target="22dd2db3-88ea-4428-a7a8-5cd3acf23175"
            type="Producer">
   <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
    <name>m-flo</name>
    <sort-name>m-flo</sort-name>
    <life-span begin="1998" />
   </artist>
  </relation>
  <relation direction="backward"
            target="a16d1433-ba89-4f72-a47b-a370add0bb55"
            type="Vocal">
   <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
    <name>BoA</name>
    <sort-name>BoA</sort-name>
    <life-span begin="1986-11-05" />
   </artist>
  </relation>
 </relation-list>
</track></metadata>';

ws_test 'lookup track with label-relationships',
    '/track/bf7845cc-eac3-48a3-8b06-543b4b7ba117?type=xml&inc=label-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="bf7845cc-eac3-48a3-8b06-543b4b7ba117">
 <title>Hey Boy Hey Girl</title>
 <duration>290853</duration>
 <relation-list target-type="Label">
  <relation direction="backward"
            target="49375f06-59e2-4c94-93ac-ac0c6df52151"
            type="Publishing">
   <label id="49375f06-59e2-4c94-93ac-ac0c6df52151">
    <name>MCA Music</name>
    <sort-name>MCA Music</sort-name>
   </label>
  </relation>
 </relation-list>
</track></metadata>';

ws_test 'lookup track with release-relationships',
    '/track/37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9">
 <title>Dear Diary</title>
 <duration>86666</duration>
 <relation-list target-type="Release">
  <relation target="4ccb3e54-caab-4ad4-94a6-a598e0e52eec" begin="2008" type="SamplesMaterial">
   <release id="4ccb3e54-caab-4ad4-94a6-a598e0e52eec" type="Spokenword Official">
    <title>An Inextricable Tale Audiobook</title>
    <text-representation script="Latn" language="ENG" />
   </release>
  </relation>
 </relation-list>
</track></metadata>';

ws_test 'lookup track with track-relationships',
    '/track/eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e?type=xml&inc=track-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
 <title>サマーれげぇ!レインボー (instrumental)</title>
 <duration>292800</duration>
 <relation-list target-type="Track">
  <relation direction="backward"
            target="162630d9-36d2-4a8d-ade1-1c77440b34e7"
            type="OtherVersion">
   <track id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
    <title>サマーれげぇ!レインボー</title>
    <duration>296026</duration>
   </track>
  </relation>
 </relation-list>
</track></metadata>';

ws_test 'lookup track with url-relationships',
    '/track/050e2f1b-ce1a-49b7-8b0b-15b1e7c5ec02?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="050e2f1b-ce1a-49b7-8b0b-15b1e7c5ec02">
 <title>Jailbait (demo)</title>
 <relation-list target-type="Url">
  <relation target="http://www.corporationblend.com/mp3s/Jailbait.mp3" type="DownloadFor Free" />
 </relation-list>
</track></metadata>';

ws_test 'lookup track with ratings',
    '/track/0d16494f-2ba4-4f4f-adf9-ae1f3ee1673d?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="0d16494f-2ba4-4f4f-adf9-ae1f3ee1673d">
 <title>The Song Remains the Same</title>
 <duration>329600</duration>
 <rating votes-count="2">60</rating>
</track></metadata>';

sub todo {

ws_test 'lookup track with user-tags',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with user-ratings',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

}

done_testing;
