use utf8;
use strict;
use Test::More;

use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

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

sub todo {

ws_test 'release with counts',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=counts' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with release-events',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=release-events' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with discs',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=discs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with tracks',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=tracks' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with release-groups',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=release-groups' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with artist-relationships',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with label-relationships',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=label-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with release-relationships',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with track-relationships',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=track-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with url-relationships',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with track-level-relationships',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=track-level-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with labels',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=labels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with tags',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with user-tags',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with ratings',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with user-ratings',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'release with isrcs',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?type=xml&inc=isrcs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

}

done_testing;
