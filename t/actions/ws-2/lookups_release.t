use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok v2_schema_validator );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $v2 = v2_schema_validator;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my $diff = XML::SemanticDiff->new;

$mech->get_ok('/ws/2/release/b3b7e934-445b-4c68-a097-730c6a6d47e6', 'basic release lookup');
&$v2 ($mech->content, "Validate basic release lookup");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
        <title>Summer Reggae! Rainbow</title><status>pseudo-release</status>
        <text-representation>
            <language>jpn</language><script>Latn</script>
        </text-representation>
        <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
    </release>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=artists', 'release lookup with artists');
&$v2 ($mech->content, "Validate release lookup with artists");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title><status>official</status>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
        <artist-credit>
            <name-credit>
                <artist type="group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </name-credit>
        </artist-credit>
    </release>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=labels+recordings', 'release lookup with labels and recordings');
&$v2 ($mech->content, "Validate release lookup with labels and recordings");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title><status>official</status>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
        <label-info-list count="1">
            <label-info>
                <catalog-number>rzcd-45118</catalog-number>
                <label>
                    <name>rhythm zone</name><sort-name>rhythm zone</sort-name>
                </label>
            </label-info>
        </label-info-list>
        <medium-list count="1">
            <medium>
                <position>1</position><format>CD</format>
                <track-list count="6">
                    <track>
                        <position>1</position>
                        <recording id="0cf3008f-e246-428f-abc1-35f87d584d60">
                            <title>the Love Bug</title><length>242226</length>
                        </recording>
                    </track>
                    <track>
                        <position>2</position>
                        <recording id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
                            <title>the Love Bug (Big Bug NYC remix)</title><length>222000</length>
                        </recording>
                    </track>
                    <track>
                        <position>3</position>
                        <recording id="3f33fc37-43d0-44dc-bfd6-60efd38810c5">
                            <title>the Love Bug (cover)</title><length>333000</length>
                        </recording>
                    </track>
                </track-list>
            </medium>
        </medium-list>
    </release>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=release-groups', 'release lookup with release-groups');
&$v2 ($mech->content, "Validate release lookup with release-groups");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title><status>official</status>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <release-group type="single" id="153f0a09-fead-3370-9b17-379ebd09446b">
            <title>the Love Bug</title>
        </release-group>
        <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
    </release>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
