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

done_testing;
