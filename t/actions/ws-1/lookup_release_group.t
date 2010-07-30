use utf8;
use strict;
use Test::More;

use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

ws_test 'release group lookup',
    '/release-group/22b54315-6e51-350b-bb34-e6e16f7688bd?type=xml' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd" type="Album">
    <title>My Demons</title>
  </release-group>
</metadata>';

done_testing;
