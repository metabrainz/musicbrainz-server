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

sub todo {

ws_test 'lookup track with artist',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=artist' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with releases',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

ws_test 'lookup track with puids',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=puids' =>
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

ws_test 'lookup track with tags',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=tags' =>
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

ws_test 'lookup track with isrcs',
    '/track/c869cc03-cb88-462b-974e-8e46c1538ad4?type=xml&inc=isrcs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" />';

}

done_testing;
