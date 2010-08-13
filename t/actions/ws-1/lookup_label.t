use utf8;
use strict;
use Test::More;

use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

ws_test 'label lookup',
    '/label/6bb73458-6c5f-4c26-8367-66fcef562955' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="6bb73458-6c5f-4c26-8367-66fcef562955" type="OriginalProduction">
    <name>zetima</name><sort-name>zetima</sort-name><country>JP</country>
  </label>
</metadata>';

ws_test 'label lookup with aliases',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="b4edce40-090f-4956-b82a-5d9d285da40b" type="OriginalProduction">
    <name>Planet Mu</name><sort-name>Planet Mu</sort-name><country>GB</country>
    <alias-list><alias>Planet µ</alias></alias-list>
  </label>
</metadata>';

ws_test 'label lookup with tags',
        '/label/6bb73458-6c5f-4c26-8367-66fcef562955?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><label id="6bb73458-6c5f-4c26-8367-66fcef562955" type="OriginalProduction"><name>zetima</name><sort-name>zetima</sort-name><country>JP</country><tag-list><tag count="1">hello project</tag></tag-list></label></metadata>';

ws_test 'label lookup with ratings',
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><label id="46f0f4cd-8aab-4b33-b698-f459faf64190" type="OriginalProduction"><name>Warp Records</name><sort-name>Warp Records</sort-name><country>GB</country><rating votes-count="1">100</rating></label></metadata>';

ws_test 'label lookup with artist-relationships',
        '/label/fe03671d-df66-4984-abbc-bd022f5c6c3f?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="fe03671d-df66-4984-abbc-bd022f5c6c3f" type="OriginalProduction">
    <name>RAM Records</name><sort-name>RAM Records</sort-name><country>GB</country>
    <relation-list target-type="Artist">
      <relation direction="backward" target="ec853694-30a1-4c7e-84e6-4ca87ee3c314" type="LabelFounder">
        <artist id="ec853694-30a1-4c7e-84e6-4ca87ee3c314" type="Person">
          <name>Andy C</name><sort-name>Andy C</sort-name><disambiguation>UK drum &amp; bass DJ/producer</disambiguation>
        </artist>
      </relation>
    </relation-list>
  </label>
</metadata>';

ws_test 'label lookup with label-relationships',
        '/label/fe03671d-df66-4984-abbc-bd022f5c6c3f?type=xml&inc=label-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="fe03671d-df66-4984-abbc-bd022f5c6c3f" type="OriginalProduction">
    <name>RAM Records</name><sort-name>RAM Records</sort-name><country>GB</country>
    <relation-list target-type="Label">
      <relation target="60a71ab7-a21b-4f25-94e0-1f51a84a9add" type="LabelOwnership">
        <label id="60a71ab7-a21b-4f25-94e0-1f51a84a9add" type="OriginalProduction">
          <name>Frequency Recordings</name><sort-name>Frequency Recordings</sort-name><country>GB</country>
        </label>
      </relation>
    </relation-list>
  </label>
</metadata>';

ws_test 'label lookup with url-relationships',
        '/label/fe03671d-df66-4984-abbc-bd022f5c6c3f?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="fe03671d-df66-4984-abbc-bd022f5c6c3f" type="OriginalProduction">
    <name>RAM Records</name><sort-name>RAM Records</sort-name><country>GB</country>
    <relation-list target-type="Url">
      <relation target="http://www.myspace.com/ramrecordsltd" type="Myspace" />
      <relation target="http://www.discogs.com/label/RAM+Records" type="Discogs" />
      <relation target="http://www.ramrecords.co.uk" type="OfficialSite" />
      <relation target="http://en.wikipedia.org/wiki/Ram_Records_(UK)" type="Wikipedia" />
    </relation-list>
  </label>
</metadata>';

ws_test 'label lookup with release-relationships',
        '/label/50c384a2-0b44-401b-b893-8181173339c7?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><label id="50c384a2-0b44-401b-b893-8181173339c7" type="OriginalProduction">
 <name>Atlantic</name>
 <sort-name>Atlantic</sort-name>
 <country>US</country>
 <relation-list target-type="Release">
  <relation target="f07d489d-a06e-4f39-b95e-5692e2a4f465" type="Publishing">
   <release id="f07d489d-a06e-4f39-b95e-5692e2a4f465" type="Album Official">
    <title>Recipe for Hate</title>
    <text-representation script="Latn" language="ENG" />
   </release>
  </relation>
  <relation target="99303476-675d-3c88-a4ee-8c40ea91b1e2" type="Publishing">
   <release id="99303476-675d-3c88-a4ee-8c40ea91b1e2" type="Album Official">
    <title>Recipe for Hate</title>
    <text-representation script="Latn" language="ENG" />
   </release>
  </relation>
 </relation-list>
</label></metadata>';

sub todo {

ws_test 'label lookup with user-tags',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'label lookup with user-ratings',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

}

done_testing;
