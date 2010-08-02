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

ws_test 'release with tags',
    '/release/0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e" type="Single Official">
    <title>サマーれげぇ!レインボー</title><text-representation script="Jpan" language="JPN" /><asin>B00005LA6G</asin>
    <tag-list>
      <tag count="1">hello project</tag><tag count="1">jpop</tag><tag count="1">sexy</tag>
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
        <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
          <sort-name>m-flo♥BoA</sort-name><name>m-flo♥BoA</name>
        </artist>
      </track>
      <track id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
        <title>the Love Bug (Big Bug NYC remix)</title>
        <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
          <sort-name>m-flo♥BoA</sort-name><name>m-flo♥BoA</name>
        </artist>
      </track>
      <track id="3f33fc37-43d0-44dc-bfd6-60efd38810c5">
        <title>the Love Bug (cover)</title>
        <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
          <sort-name></sort-name><name>BAGDAD CAFE THE trench town</name>
        </artist>
      </track>
    </track-list>
    <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
      <sort-name>m-flo</sort-name><name>m-flo</name>
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
