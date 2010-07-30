use utf8;
use strict;
use Test::More;

use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

ws_test 'label lookup',
    '/label/6bb73458-6c5f-4c26-8367-66fcef562955' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="6bb73458-6c5f-4c26-8367-66fcef562955" type="OriginalProduction">
    <name>zetima</name><sort-name>zetima</sort-name><country>JP</country>
  </label>
</metadata>';

done_testing;
