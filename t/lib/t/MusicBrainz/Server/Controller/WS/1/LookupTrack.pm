package t::MusicBrainz::Server::Controller::WS::1::LookupTrack;
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
INSERT INTO link_type
    (id, parent, child_order, gid, entity_type0, entity_type1,
     name, description, link_phrase, reverse_link_phrase, long_link_phrase)
VALUES (251, NULL, 1, '45d0cbc5-d65b-4e77-bdfd-8a75207cb5c5', 'recording', 'url',
        'download for free', 'Indicates a webpage where you can download',
        'download for free', 'free download page for', 'download for free');
INSERT INTO link (id, link_type, attribute_count) VALUES (24957, 251, 0);
INSERT INTO l_recording_url (id, link, entity0, entity1)
    VALUES (9000, 24957, 4223059, 195251);
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca');
EOSQL

MusicBrainz::Server::Test->prepare_raw_test_database(
    $c, <<'EOSQL');
TRUNCATE recording_tag_raw CASCADE;
TRUNCATE recording_rating_raw CASCADE;

INSERT INTO recording_tag_raw (recording, editor, tag)
    VALUES (4223061, 1, 114);

INSERT INTO recording_rating_raw (recording, editor, rating)
    VALUES (160074, 1, 100);
EOSQL

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
    '/track/7a356856-9483-42c2-bed9-dc07cb555952?type=xml&inc=tags' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" >
  <track id="7a356856-9483-42c2-bed9-dc07cb555952">
    <title>Cella</title><duration>334000</duration>
    <tag-list><tag count="1">dubstep</tag></tag-list>
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

ws_test 'lookup track by puid',
    '/track/?type=xml&puid=24dd0c12-3f22-955d-f35e-d3d8867eee8d' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" >
    <track-list>
        <track id="7e379a1d-f2bc-47b8-964e-00723df34c8a">
            <title>Be Rude to Your School</title><duration>208706</duration>
            <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4">
                <name>Plone</name><sort-name>Plone</sort-name>
            </artist>
            <release-list>
                <release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221">
                    <title>For Beginner Piano</title>
                </release>
                <release id="dd66bfdd-6097-32e3-91b6-67f47ba25d4c">
                    <title>For Beginner Piano</title>
                </release>
                <release id="fbe4eb72-0f24-3875-942e-f581589713d4">
                    <title>For Beginner Piano</title>
                </release>
            </release-list>
        </track>
    </track-list>
</metadata>
';

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
      <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
        <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" />
        <track-list offset="0" />
      </release>
      <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6" type="Single Pseudo-Release">
        <title>Summer Reggae! Rainbow</title><text-representation script="Latn" language="JPN" />
        <track-list offset="0" />
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
            type="Producer">
   <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
    <name>m-flo</name>
    <sort-name>m-flo</sort-name>
    <life-span begin="1998" />
   </artist>
  </relation>
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
            target="a16d1433-ba89-4f72-a47b-a370add0bb55"
            type="Vocal" attributes="Guest">
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
    <artist id="05d83760-08b5-42bb-a8d7-00d80b3bf47c"><name>Paul Allgood</name><sort-name>Allgood, Paul</sort-name></artist>
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
            type="Karaoke">
   <track id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
    <title>サマーれげぇ!レインボー</title>
    <duration>296026</duration>
    <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f"><name>7人祭</name><sort-name>7nin Matsuri</sort-name></artist>
   </track>
  </relation>
 </relation-list>
</track></metadata>';

ws_test 'lookup track with url-relationships',
    '/track/162630d9-36d2-4a8d-ade1-1c77440b34e7?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
 <title>サマーれげぇ!レインボー</title><duration>296026</duration>
 <relation-list target-type="Url">
  <relation target="http://en.wikipedia.org/wiki/Freestyle_Dust" type="DownloadForFree" />
 </relation-list>
</track></metadata>';

ws_test 'lookup track with ratings',
    '/track/0d16494f-2ba4-4f4f-adf9-ae1f3ee1673d?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="0d16494f-2ba4-4f4f-adf9-ae1f3ee1673d">
 <title>The Song Remains the Same</title>
 <duration>329600</duration>
 <rating votes-count="2">3</rating>
</track></metadata>';

ws_test 'lookup track with user-tags',
    '/track/eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <track id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
    <title>サマーれげぇ!レインボー (instrumental)</title><duration>292800</duration>
    <user-tag-list>
      <user-tag>hello project</user-tag>
    </user-tag-list>
  </track>
</metadata>',
    { username => 'editor', password => 'password' };

ws_test 'lookup track with ratings',
    '/track/0d16494f-2ba4-4f4f-adf9-ae1f3ee1673d?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="0d16494f-2ba4-4f4f-adf9-ae1f3ee1673d">
 <title>The Song Remains the Same</title>
 <duration>329600</duration>
 <user-rating>5</user-rating>
</track></metadata>',
    { username => 'editor', password => 'password' };

};

1;

