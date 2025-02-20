package t::MusicBrainz::Server::Controller::WS::2::LookupURL;
use utf8;
use strict;
use warnings;

use Test::Routine;

with 't::Mechanize', 't::Context';

use MusicBrainz::Server::Test::WS qw(
    ws2_test_xml
    ws2_test_xml_not_found
);

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;
$mech->default_header('Accept' => 'application/xml');

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws2_test_xml 'basic url lookup',
    '/url/e0a79771-e9f0-4127-b58a-f5e6869c8e96' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <url id="e0a79771-e9f0-4127-b58a-f5e6869c8e96">
      <resource>http://www.discogs.com/artist/Paul+Allgood</resource>
    </url>
</metadata>';

ws2_test_xml 'basic url lookup (by URL)',
    '/url?resource=http://www.discogs.com/artist/Paul%2BAllgood' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <url id="e0a79771-e9f0-4127-b58a-f5e6869c8e96">
      <resource>http://www.discogs.com/artist/Paul+Allgood</resource>
    </url>
</metadata>';

ws2_test_xml 'multiple url lookup (by URL, with inc=artist-rels+release-rels)',
    '/url?resource=http://www.discogs.com/artist/Paul%2BAllgood' .
        '&resource=http://www.discogs.com/release/30896' .
        '&inc=artist-rels+release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <url-list count="2">
    <url id="e0a79771-e9f0-4127-b58a-f5e6869c8e96">
      <resource>http://www.discogs.com/artist/Paul+Allgood</resource>
      <relation-list target-type="artist">
        <relation type="discogs" type-id="04a5b104-a4c2-4bac-99a1-7b837c37d9e4">
          <target>05d83760-08b5-42bb-a8d7-00d80b3bf47c</target>
          <direction>backward</direction>
          <artist id="05d83760-08b5-42bb-a8d7-00d80b3bf47c" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
            <name>Paul Allgood</name>
            <sort-name>Allgood, Paul</sort-name>
          </artist>
        </relation>
      </relation-list>
    </url>
    <url id="9bd7cece-05e3-438b-a2a1-070f8a829ed5">
      <resource>http://www.discogs.com/release/30896</resource>
      <relation-list target-type="release">
        <relation type="discogs" type-id="4a78823c-1c53-4176-a5f3-58026c76f2bc">
          <target>4f5a6b97-a09b-4893-80d1-eae1f3bfa221</target>
          <direction>backward</direction>
          <release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221">
            <title>For Beginner Piano</title>
            <quality>normal</quality>
            <text-representation>
              <language>eng</language>
              <script>Latn</script>
            </text-representation>
            <date>1999-09-13</date>
            <country>GB</country>
            <release-event-list count="1">
              <release-event>
                <date>1999-09-13</date>
                <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
                  <name>United Kingdom</name>
                  <sort-name>United Kingdom</sort-name>
                  <iso-3166-1-code-list>
                    <iso-3166-1-code>GB</iso-3166-1-code>
                  </iso-3166-1-code-list>
                </area>
              </release-event>
            </release-event-list>
            <barcode>5021603064126</barcode>
          </release>
        </relation>
        <relation type="discogs" type-id="4a78823c-1c53-4176-a5f3-58026c76f2bc">
          <target>fbe4eb72-0f24-3875-942e-f581589713d4</target>
          <direction>backward</direction>
          <release id="fbe4eb72-0f24-3875-942e-f581589713d4">
            <title>For Beginner Piano</title>
            <quality>normal</quality>
            <text-representation>
              <language>eng</language>
              <script>Latn</script>
            </text-representation>
            <date>1999-09-23</date>
            <country>US</country>
            <release-event-list count="1">
              <release-event>
                <date>1999-09-23</date>
                <area id="489ce91b-6658-3307-9877-795b68554c98">
                  <name>United States</name>
                  <sort-name>United States</sort-name>
                  <iso-3166-1-code-list>
                    <iso-3166-1-code>US</iso-3166-1-code>
                  </iso-3166-1-code-list>
                </area>
              </release-event>
            </release-event-list>
          </release>
        </relation>
        <relation type="discogs" type-id="4a78823c-1c53-4176-a5f3-58026c76f2bc">
          <target>dd66bfdd-6097-32e3-91b6-67f47ba25d4c</target>
          <direction>backward</direction>
          <release id="dd66bfdd-6097-32e3-91b6-67f47ba25d4c">
            <title>For Beginner Piano</title>
            <quality>normal</quality>
            <text-representation>
              <language>eng</language>
              <script>Latn</script>
            </text-representation>
            <date>1999-09-13</date>
            <country>GB</country>
            <release-event-list count="1">
              <release-event>
                <date>1999-09-13</date>
                <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
                  <name>United Kingdom</name>
                  <sort-name>United Kingdom</sort-name>
                  <iso-3166-1-code-list>
                    <iso-3166-1-code>GB</iso-3166-1-code>
                  </iso-3166-1-code-list>
                </area>
              </release-event>
            </release-event-list>
            <barcode/>
          </release>
        </relation>
      </relation-list>
    </url>
  </url-list>
</metadata>';

ws2_test_xml_not_found 'basic url lookup (by URL, 404)',
    '/url?resource=http://www.disscog.com/artist/Paul%2BAllgood';

ws2_test_xml 'multiple url lookup (by URL, none found)',
    '/url?resource=http://www.disscog.com/artist/Paul%2BAllgood' .
        '&resource=http://www.disscog.com/release/30896' .
        '&inc=artist-rels+release-rels' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <url-list count="0"/>
</metadata>';

ws2_test_xml 'basic url lookup (with inc=artist-rels)',
    '/url/e0a79771-e9f0-4127-b58a-f5e6869c8e96?inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <url id="e0a79771-e9f0-4127-b58a-f5e6869c8e96">
      <resource>http://www.discogs.com/artist/Paul+Allgood</resource>
      <relation-list target-type="artist">
        <relation type-id="04a5b104-a4c2-4bac-99a1-7b837c37d9e4" type="discogs">
          <target>05d83760-08b5-42bb-a8d7-00d80b3bf47c</target>
          <direction>backward</direction>
          <artist id="05d83760-08b5-42bb-a8d7-00d80b3bf47c" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
            <name>Paul Allgood</name>
            <sort-name>Allgood, Paul</sort-name>
          </artist>
        </relation>
      </relation-list>
    </url>
</metadata>';

};

1;

