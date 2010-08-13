use utf8;
use strict;
use Test::More;

use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };
ws_test 'artist lookup with aliases',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55" type="Person">
        <name>BoA</name><sort-name>BoA</sort-name><life-span begin="1986-11-05" />
        <alias-list>
            <alias>Beat of Angel</alias><alias>BoA Kwon</alias><alias>Kwon BoA</alias><alias>보아</alias><alias>ボア</alias>
        </alias-list>
    </artist>
</metadata>';

ws_test 'artist lookup with release groups',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?type=xml&inc=release-groups+sa-Album' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person">
        <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        <release-list>
            <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official" >
                <title>My Demons</title><text-representation language="ENG" script="Latn"/>
                <asin>B000KJTG6K</asin><release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd"/>
            </release>
            <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134" type="Album Official" >
                <title>Repercussions</title><text-representation language="ENG" script="Latn"/>
                <asin>B001IKWNCE</asin><release-group id="56683a0b-45b8-3664-a231-5b68efe2e7e2"/>
            </release>
        </release-list>
        <release-group-list>
            <release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd" type="Album" >
                <title>My Demons</title>
            </release-group>
            <release-group id="56683a0b-45b8-3664-a231-5b68efe2e7e2" type="Album" >
                <title>Repercussions</title>
            </release-group>
        </release-group-list>
    </artist>
</metadata>';

ws_test 'artist lookup with URL relationships',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
        <name>BAGDAD CAFE THE trench town</name><sort-name>BAGDAD CAFE THE trench town</sort-name>
        <relation-list target-type="Url">
            <relation type="OfficialHomepage" target="http://www.mop2001.com/bag.html"/>
        </relation-list>
    </artist>
</metadata>';

ws_test 'artist lookup with tags',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f" type="Group"><name>7人祭</name><sort-name>7nin Matsuri</sort-name><tag-list><tag count="1">country-jp</tag><tag count="1">hello project</tag><tag count="1">hello project groups</tag><tag count="1">hello project shuffle units</tag></tag-list></artist></metadata>';

ws_test 'artist lookup with release-relationships',
    '/artist/3088b672-fba9-4b4b-8ae0-dce13babfbb4?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group"><name>Plone</name><sort-name>Plone</sort-name><relation-list target-type="Release"><relation target="fbe4eb72-0f24-3875-942e-f581589713d4" type="Design/Illustration"><release id="fbe4eb72-0f24-3875-942e-f581589713d4" type="Album Official"><title>For Beginner Piano</title><text-representation script="Latn" language="ENG" /></release></relation><relation target="dd66bfdd-6097-32e3-91b6-67f47ba25d4c" type="Design/Illustration"><release id="dd66bfdd-6097-32e3-91b6-67f47ba25d4c" type="Album Official"><title>For Beginner Piano</title><text-representation script="Latn" language="ENG" /></release></relation><relation target="4f5a6b97-a09b-4893-80d1-eae1f3bfa221" type="Design/Illustration"><release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221" type="Album Official"><title>For Beginner Piano</title><text-representation script="Latn" language="ENG" /></release></relation></relation-list></artist></metadata>';

ws_test 'artist lookup with track-relationships',
    '/artist/3088b672-fba9-4b4b-8ae0-dce13babfbb4?type=xml&inc=track-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group"><name>Plone</name><sort-name>Plone</sort-name><relation-list target-type="Track"><relation target="44704dda-b877-4551-a2a8-c1f764476e65" type="Producer"><track id="44704dda-b877-4551-a2a8-c1f764476e65"><title>On My Bus</title><duration>267560</duration></track></relation><relation target="8920288e-7541-48a7-b23b-f80447c8b1ab" type="Producer"><track id="8920288e-7541-48a7-b23b-f80447c8b1ab"><title>Top &amp; Low Rent</title><duration>230506</duration></track></relation><relation target="6e89c516-b0b6-4735-a758-38e31855dcb6" type="Producer"><track id="6e89c516-b0b6-4735-a758-38e31855dcb6"><title>Plock</title><duration>237133</duration></track></relation><relation target="791d9b27-ae1a-4295-8943-ded4284f2122" type="Producer"><track id="791d9b27-ae1a-4295-8943-ded4284f2122"><title>Marbles</title><duration>229826</duration></track></relation><relation target="4f392ffb-d3df-4f8a-ba74-fdecbb1be877" type="Producer"><track id="4f392ffb-d3df-4f8a-ba74-fdecbb1be877"><title>Busy Working</title><duration>217440</duration></track></relation><relation target="dc891eca-bf42-4103-8682-86068fe732a5" type="Producer"><track id="dc891eca-bf42-4103-8682-86068fe732a5"><title>The Greek Alphabet</title><duration>227293</duration></track></relation><relation target="25e9ae0f-8b7d-4230-9cde-9a07f7680e4a" type="Producer"><track id="25e9ae0f-8b7d-4230-9cde-9a07f7680e4a"><title>Press a Key</title><duration>244506</duration></track></relation><relation target="6f9c8c32-3aae-4dad-b023-56389361cf6b" type="Producer"><track id="6f9c8c32-3aae-4dad-b023-56389361cf6b"><title>Bibi Plone</title><duration>173960</duration></track></relation><relation target="7e379a1d-f2bc-47b8-964e-00723df34c8a" type="Producer"><track id="7e379a1d-f2bc-47b8-964e-00723df34c8a"><title>Be Rude to Your School</title><duration>208706</duration></track></relation><relation target="a8614bda-42dc-43c7-ac5f-4067acb6f1c5" type="Producer"><track id="a8614bda-42dc-43c7-ac5f-4067acb6f1c5"><title>Summer Plays Out</title><duration>320067</duration></track></relation></relation-list></artist></metadata>';

ws_test 'artist lookup with ratings',
    '/artist/3088b672-fba9-4b4b-8ae0-dce13babfbb4?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group"><name>Plone</name><sort-name>Plone</sort-name><rating votes-count="2">70</rating></artist></metadata>';

ws_test 'artist lookup with release-events',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?type=xml&inc=release-events+sa-Album' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person">
    <name>Distance</name><sort-name>Distance</sort-name>
    <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    <release-list>
      <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
        <title>My Demons</title><text-representation script="Latn" language="ENG" /><asin>B000KJTG6K</asin>
        <release-event-list>
          <event country="GB" format="CD" date="2007-01-29" barcode="600116817020" catalog-number="ZIQ170CD" />
        </release-event-list>
      </release>
      <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134" type="Album Official">
        <title>Repercussions</title><text-representation script="Latn" language="ENG" /><asin>B001IKWNCE</asin>
        <release-event-list>
          <event country="GB" format="2xCD" date="2008-11-17" barcode="600116822123" catalog-number="ZIQ221CD" />
        </release-event-list>
      </release>
    </release-list>
  </artist>
</metadata>';

ws_test 'artist lookup with release-events',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?type=xml&inc=release-events+sa-Album+labels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person">
    <name>Distance</name><sort-name>Distance</sort-name>
    <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    <release-list>
      <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
        <title>My Demons</title><text-representation script="Latn" language="ENG" /><asin>B000KJTG6K</asin>
        <release-event-list>
          <event country="GB" format="CD" date="2007-01-29" barcode="600116817020" catalog-number="ZIQ170CD">
            <label id="b4edce40-090f-4956-b82a-5d9d285da40b">
              <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
            </label>
          </event>
        </release-event-list>
      </release>
      <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134" type="Album Official">
        <title>Repercussions</title><text-representation script="Latn" language="ENG" /><asin>B001IKWNCE</asin>
        <release-event-list>
          <event country="GB" format="2xCD" date="2008-11-17" barcode="600116822123" catalog-number="ZIQ221CD">
            <label id="b4edce40-090f-4956-b82a-5d9d285da40b">
              <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
            </label>
          </event>
        </release-event-list>
      </release>
    </release-list>
  </artist>
</metadata>';

ws_test 'artist lookup with discs',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?type=xml&inc=discs+sa-Single' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f" type="Group">
    <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
    <release-list>
      <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6" type="Single Pseudo-Release">
        <title>Summer Reggae! Rainbow</title><text-representation script="Latn" language="JPN" />
        <asin>B00005LA6G</asin>
        <disc-list>
          <disc sectors="60295" id="W01Qvrvwkaz2Cm.IQm55_RHoRxs-"/>
        </disc-list>
      </release>
      <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
        <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" />
        <asin>B00005LA6G</asin>
        <disc-list>
          <disc sectors="60295" id="W01Qvrvwkaz2Cm.IQm55_RHoRxs-"/>
        </disc-list>
      </release>
    </release-list>
  </artist>
</metadata>';

ws_test 'artist lookup with counts',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?type=xml&inc=counts+sa-Single' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f" type="Group">
    <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
    <release-list>
      <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6" type="Single Pseudo-Release">
        <title>Summer Reggae! Rainbow</title><text-representation script="Latn" language="JPN" />
        <asin>B00005LA6G</asin>
        <release-event-list count="1"/>
        <disc-list count="1"/>
        <track-list count="3"/>
      </release>
      <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
        <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" />
        <asin>B00005LA6G</asin>
        <release-event-list count="1"/>
        <disc-list count="1"/>
        <track-list count="3"/>
      </release>
    </release-list>
  </artist>
</metadata>';

ws_test 'artist lookup with label-relationships',
    '/artist/ec853694-30a1-4c7e-84e6-4ca87ee3c314?type=xml&inc=label-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <artist id="ec853694-30a1-4c7e-84e6-4ca87ee3c314" type="Person">
   <name>Andy C</name><sort-name>Andy C</sort-name>
   <disambiguation>UK drum &amp; bass DJ/producer</disambiguation>
   <relation-list target-type="Label">
     <relation target="fe03671d-df66-4984-abbc-bd022f5c6c3f" type="LabelFounder">
       <label id="fe03671d-df66-4984-abbc-bd022f5c6c3f">
         <name>RAM Records</name>
         <sort-name>RAM Records</sort-name>
       </label>
     </relation>
     <relation target="60a71ab7-a21b-4f25-94e0-1f51a84a9add" type="LabelFounder">
       <label id="60a71ab7-a21b-4f25-94e0-1f51a84a9add">
         <name>Frequency Recordings</name>
         <sort-name>Frequency Recordings</sort-name>
       </label>
     </relation>
    </relation-list>
  </artist>
</metadata>';

ws_test 'artist lookup with artist-relationships',
    '/artist/6fe9f838-112e-44f1-af83-97464f08285b?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
<artist id="6fe9f838-112e-44f1-af83-97464f08285b" type="Group">
 <name>Wedlock</name>
 <sort-name>Wedlock</sort-name>
 <disambiguation>USA electro pop</disambiguation>
 <life-span begin="2004" />
 <relation-list target-type="Artist">
  <relation direction="backward"
            target="05d83760-08b5-42bb-a8d7-00d80b3bf47c"
            type="MemberOf Band">
   <artist id="05d83760-08b5-42bb-a8d7-00d80b3bf47c">
    <name>Paul Allgood</name>
    <sort-name>Allgood, Paul</sort-name>
   </artist>
  </relation>
 </relation-list>
</artist></metadata>';

sub todo {

ws_test 'artist lookup with user-ratings',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with user-tags',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

}

done_testing;
