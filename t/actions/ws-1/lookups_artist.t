use utf8;
use strict;
use Test::More;

use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

ws_test 'artist lookup with aliases',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55" type="Person">
        <name>BoA</name><sort-name>BoA</sort-name><life-span begin="1986-11-05" />
        <alias-list>
            <alias>Beat of Angel</alias><alias>BoA Kwon</alias><alias>Kwon BoA</alias><alias>보아</alias><alias>ボア</alias>
        </alias-list>
    </artist>
</metadata>';

ws_test 'artist lookup with release groups',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?type=xml&inc=release-groups+sa-Album' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person">
        <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        <release-list>
            <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official" >
                <title>My Demons</title><text-representation language="ENG" script="Latn"/>
                <asin>B000KJTG6K</asin><release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd"/>
            </release>
            <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134" type="Album Official" >
                <title>Repercussions</title><text-representation language="ENG" script="Latn"/>
                <asin>B001IKWNCE</asin><release-group id="56683a0b-45b8-3664-a231-5b68efe2e7e2"/>
            </release>
        </release-list>
        <release-group-list>
            <release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd" type="Album" >
                <title>My Demons</title>
            </release-group>
            <release-group id="56683a0b-45b8-3664-a231-5b68efe2e7e2" type="Album" >
                <title>Repercussions</title>
            </release-group>
        </release-group-list>
    </artist>
</metadata>';

ws_test 'artist lookup with artist-relationships',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with label-relationships',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=label-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with release-relationships',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with track-relationships',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=track-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with ratings',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with user-ratings',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=user-ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with tags',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with user-tags',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=user-tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with counts',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=counts' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with release-events',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=release-events' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with discs',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=discs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with labels',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=labels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata />';

ws_test 'artist lookup with URL relationships',
    '/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
        <name>BAGDAD CAFE THE trench town</name><sort-name>BAGDAD CAFE THE trench town</sort-name>
        <relation-list target-type="Url">
            <relation type="OfficialHomepage" target="http://www.mop2001.com/bag.html" begin="" end=""/>
        </relation-list>
    </artist>
</metadata>';

done_testing;
