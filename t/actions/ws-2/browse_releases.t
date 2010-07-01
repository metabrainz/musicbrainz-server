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

$mech->get_ok('/ws/2/release?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4', 'browse releases via artist');
&$v2 ($mech->content, "Validate browse releases via artist");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="3">
        <release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221">
            <title>For Beginner Piano</title><status>official</status>
            <text-representation>
                <language>eng</language><script>Latn</script>
            </text-representation>
            <date>1999-09-13</date><country>GB</country><barcode>5021603064126</barcode>
        </release>
        <release id="dd66bfdd-6097-32e3-91b6-67f47ba25d4c">
            <title>For Beginner Piano</title><status>official</status>
            <text-representation>
                <language>eng</language><script>Latn</script>
            </text-representation>
            <date>1999-09-13</date><country>GB</country>
        </release>
        <release id="fbe4eb72-0f24-3875-942e-f581589713d4">
            <title>For Beginner Piano</title><status>official</status>
            <text-representation>
                <language>eng</language><script>Latn</script>
            </text-representation>
            <date>1999-09-23</date><country>US</country>
        </release>
    </release-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/release?inc=mediums&label=b4edce40-090f-4956-b82a-5d9d285da40b', 'browse releases via label');
&$v2 ($mech->content, "Validate browse releases via label");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="2">
        <release id="adcf7b48-086e-48ee-b420-1001f88d672f">
            <title>My Demons</title><status>official</status>
            <text-representation>
                <language>eng</language><script>Latn</script>
            </text-representation>
            <date>2007-01-29</date><country>GB</country>
            <medium-list count="1">
                <medium>
                    <position>1</position><format>CD</format><track-list count="12" />
                </medium>
            </medium-list>
        </release>
        <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134">
            <title>Repercussions</title><status>official</status>
            <text-representation>
                <language>eng</language><script>Latn</script>
            </text-representation>
            <date>2008-11-17</date><country>GB</country>
            <medium-list count="2">
                <medium>
                    <position>1</position><format>CD</format><track-list count="9" />
                </medium>
                <medium>
                    <title>Chestplate Singles</title><position>2</position><format>CD</format><track-list count="9" />
                </medium>
            </medium-list>
        </release>
    </release-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');


$mech->get_ok('/ws/2/release?release-group=b84625af-6229-305f-9f1b-59c0185df016', 'browse releases via release group');
&$v2 ($mech->content, "Validate browse releases via release-group");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="2">
        <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
            <title>Summer Reggae! Rainbow</title><status>pseudo-release</status>
            <text-representation>
                <language>jpn</language><script>Latn</script>
            </text-representation>
            <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
        </release>
        <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
            <title>サマーれげぇ!レインボー</title><status>official</status>
            <text-representation>
                <language>jpn</language><script>Jpan</script>
            </text-representation>
            <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
        </release>
    </release-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');


my $response = $mech->get('/ws/2/release?recording=7b1f6e95-b523-43b6-a048-810ea5d463a8');
is ($response->code, 404, 'browse releases via non-existent recording');

$mech->get_ok('/ws/2/release?inc=labels&recording=0c0245df-34f0-416b-8c3f-f20f66e116d0', 'browse releases via recording');
&$v2 ($mech->content, "Validate browse releases via recording");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="3">
        <release id="757a1723-3769-4298-89cd-48d31177852a">
            <title>LOVE &amp; HONESTY</title><status>pseudo-release</status>
            <text-representation>
                <language>jpn</language><script>Latn</script>
            </text-representation>
            <date>2004-01-15</date><country>JP</country>
            <label-info-list count="1">
                <label-info>
                    <label>
                        <name>avex trax</name><sort-name>avex trax</sort-name>
                    </label>
                </label-info>
            </label-info-list>
        </release>
        <release id="cacc586f-c2f2-49db-8534-6f44b55196f2">
            <title>LOVE &amp; HONESTY</title><status>official</status>
            <text-representation>
                <language>jpn</language><script>Jpan</script>
            </text-representation>
            <date>2004-01-15</date><country>JP</country><barcode>4988064173907</barcode>
            <label-info-list count="1">
                <label-info>
                    <catalog-number>avcd-17390</catalog-number>
                    <label>
                        <name>avex trax</name><sort-name>avex trax</sort-name>
                    </label>
                </label-info>
            </label-info-list>
        </release>
        <release id="28fc2337-985b-3da9-ac40-ad6f28ff0d8e">
            <title>LOVE &amp; HONESTY</title><status>official</status>
            <text-representation>
                <language>jpn</language><script>Jpan</script>
            </text-representation>
            <date>2004-01-15</date><country>JP</country><barcode>4988064173891</barcode>
            <label-info-list count="1">
                <label-info>
                    <catalog-number>avcd-17389</catalog-number>
                    <label>
                        <name>avex trax</name><sort-name>avex trax</sort-name>
                    </label>
                </label-info>
            </label-info-list>
        </release>
    </release-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
