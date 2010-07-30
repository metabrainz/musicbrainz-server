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

ws_test 'label lookup with aliases',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <label id="b4edce40-090f-4956-b82a-5d9d285da40b" type="OriginalProduction">
    <name>Planet Mu</name><sort-name>Planet Mu</sort-name><country>GB</country>
    <alias-list><alias>Planet µ</alias></alias-list>
  </label>
</metadata>';

ws_test 'label lookup with tags',
        '/label/6bb73458-6c5f-4c26-8367-66fcef562955?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><label id="6bb73458-6c5f-4c26-8367-66fcef562955" type="OriginalProduction"><name>zetima</name><sort-name>zetima</sort-name><country>JP</country><tag-list><tag count="1">hello project</tag></tag-list></label></metadata>';

sub todo {

ws_test 'label lookup with artist-relationships',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'label lookup with label-relationships',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=label-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'label lookup with release-relationships',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'label lookup with url-relationships',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'label lookup with user-tags',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'label lookup with ratings',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'label lookup with user-ratings',
        '/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

}

done_testing;
