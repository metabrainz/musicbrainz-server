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

sub todo {

ws_test 'lookup track with releases',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with artist-relationships',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with label-relationships',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=label-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with release-relationships',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with track-relationships',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=track-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with url-relationships',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with user-tags',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with ratings',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with user-ratings',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

}

done_testing;
