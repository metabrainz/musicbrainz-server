use utf8;
use strict;
use Test::More;

use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

MusicBrainz::Server::Test->prepare_test_server;

ws_test 'search for artists by name',
    '/artist/?type=xml&name=Distance',
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" xmlns:ext="http://musicbrainz.org/ns/ext-1.0#">
  <artist-list>
    <artist />
  </artist-list>
</metadata>';

done_testing;
