package t::MusicBrainz::Server::Controller::WS::1::LookupLabel;
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
TRUNCATE label_tag_raw CASCADE;
TRUNCATE label_rating_raw CASCADE;

INSERT INTO label_tag_raw (label, editor, tag)
    VALUES (381, 1, 114);

INSERT INTO label_rating_raw (label, editor, rating)
    VALUES (46, 1, 100);
EOSQL

ws_test 'label lookup',
    '/label/6bb73458-6c5f-4c26-8367-66fcef562955' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="6bb73458-6c5f-4c26-8367-66fcef562955" type="OriginalProduction">
    <name>zetima</name>
    <sort-name>zetima</sort-name>
    <country>JP</country>
  </label>
</metadata>';

ws_test 'label lookup with aliases',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="b4edce40-090f-4956-b82a-5d9d285da40b" type="OriginalProduction">
    <name>Planet Mu</name>
    <sort-name>Planet Mu</sort-name>
    <country>GB</country>
    <life-span begin="1995" />
    <alias-list><alias>Planet µ</alias></alias-list>
  </label>
</metadata>';

ws_test 'label lookup with tags',
        '/label/6bb73458-6c5f-4c26-8367-66fcef562955?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="6bb73458-6c5f-4c26-8367-66fcef562955" type="OriginalProduction">
    <name>zetima</name>
    <sort-name>zetima</sort-name>
    <country>JP</country>
    <tag-list>
        <tag count="1">hello project</tag>
    </tag-list>
    </label>
</metadata>';

ws_test 'label lookup with ratings',
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <label id="46f0f4cd-8aab-4b33-b698-f459faf64190" type="OriginalProduction">
        <name>Warp Records</name>
        <sort-name>Warp Records</sort-name>
        <label-code>2070</label-code>
        <country>GB</country>
        <life-span begin="1989" />
        <rating votes-count="1">5</rating>
    </label>
</metadata>';

ws_test 'label lookup with artist-relationships',
        '/label/fe03671d-df66-4984-abbc-bd022f5c6c3f?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="fe03671d-df66-4984-abbc-bd022f5c6c3f" type="OriginalProduction">
    <name>RAM Records</name>
    <sort-name>RAM Records</sort-name>
    <country>GB</country>
    <life-span begin="1992" />
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
    <name>RAM Records</name>
    <sort-name>RAM Records</sort-name>
    <country>GB</country>
    <life-span begin="1992" />
    <relation-list target-type="Label">
     <relation target="60a71ab7-a21b-4f25-94e0-1f51a84a9add" type="LabelOwnership">
        <label id="60a71ab7-a21b-4f25-94e0-1f51a84a9add" type="OriginalProduction">
          <name>Frequency Recordings</name><sort-name>Frequency Recordings</sort-name><country>GB</country>
          <life-span begin="2001" />
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
    <name>RAM Records</name>
    <sort-name>RAM Records</sort-name>
    <country>GB</country>
    <life-span begin="1992" />
    <relation-list target-type="Url">
      <relation target="http://en.wikipedia.org/wiki/Ram_Records_(UK)" type="Wikipedia" />
      <relation target="http://www.discogs.com/label/RAM+Records" type="Discogs" />
      <relation target="http://www.myspace.com/ramrecordsltd" type="Myspace" />
      <relation target="http://www.ramrecords.co.uk/" type="OfficialSite" />
    </relation-list>
  </label>
</metadata>';

ws_test 'label lookup with release-relationships',
        '/label/50c384a2-0b44-401b-b893-8181173339c7?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="50c384a2-0b44-401b-b893-8181173339c7" type="OriginalProduction">
    <name>Atlantic</name>
    <sort-name>Atlantic</sort-name>
    <label-code>121</label-code>
    <country>US</country>
    <life-span begin="1947" />
    <relation-list target-type="Release">
      <relation target="99303476-675d-3c88-a4ee-8c40ea91b1e2" type="Publishing">
        <release id="99303476-675d-3c88-a4ee-8c40ea91b1e2" type="Album Official">
          <title>Recipe for Hate</title>
          <text-representation script="Latn" language="ENG" />
          <artist id="149e6720-4e4a-41a4-afca-6d29083fc091">
            <name>Bad Religion</name>
            <sort-name>Bad Religion</sort-name>
          </artist>
        </release>
      </relation>
      <relation target="f07d489d-a06e-4f39-b95e-5692e2a4f465" type="Publishing">
        <release id="f07d489d-a06e-4f39-b95e-5692e2a4f465" type="Album Official">
          <title>Recipe for Hate</title>
          <text-representation script="Latn" language="ENG" />
          <artist id="149e6720-4e4a-41a4-afca-6d29083fc091">
            <name>Bad Religion</name>
            <sort-name>Bad Religion</sort-name>
          </artist>
        </release>
      </relation>
    </relation-list>
  </label>
</metadata>';

ws_test 'label lookup with tags',
        '/label/6bb73458-6c5f-4c26-8367-66fcef562955?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="6bb73458-6c5f-4c26-8367-66fcef562955" type="OriginalProduction">
    <name>zetima</name>
    <sort-name>zetima</sort-name>
    <country>JP</country>
    <user-tag-list>
      <user-tag>hello project</user-tag>
    </user-tag-list>
  </label>
</metadata>',
    { username => 'editor', password => 'password' };

ws_test 'label lookup with ratings',
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <label id="46f0f4cd-8aab-4b33-b698-f459faf64190" type="OriginalProduction">
        <name>Warp Records</name>
        <sort-name>Warp Records</sort-name>
        <label-code>2070</label-code>
        <country>GB</country>
        <life-span begin="1989" />
        <user-rating>5</user-rating>
    </label>
</metadata>',
   { username => 'editor', password => 'password' };

};

1;

