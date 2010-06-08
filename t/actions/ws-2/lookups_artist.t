use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use XML::SemanticCompare;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok v2_schema_validator );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $v2 = v2_schema_validator;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my $diff = XML::SemanticDiff->new;

$mech->get_ok('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a', 'basic artist lookup');
&$v2 ($mech->content, "Validate basic artist lookup");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name>
        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/f26c72d3-e52c-467b-b651-679c73d8e1a7?inc=aliases', 'artist lookup, inc=aliases');
&$v2 ($mech->content, "Validate artist lookup with aliases");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="group" id="f26c72d3-e52c-467b-b651-679c73d8e1a7">
        <name>!!!</name><sort-name>!!!</sort-name>
        <life-span><begin>1996</begin></life-span>
        <alias-list count="9">
            <alias>exclamation exclamation exclamation</alias>
            <alias>Chik Chik Chik</alias>
            <alias>ChkChk</alias>
            <alias>Chkchkchk (!!!)</alias>
            <alias>chk chk chk</alias>
            <alias>pow pow pow</alias>
            <alias>chick chick chick</alias>
            <alias>Chkchkchk</alias>
            <alias>chk-chk-chk</alias>
        </alias-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f/releases', 'artist lookup with releases');
&$v2 ($mech->content, "Validate artist lookup with releases");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f" type="group">
        <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
        <release-list count="2">
            <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
                <title>Summer Reggae! Rainbow</title>
                <status>pseudo-release</status>
                <text-representation>
                    <language>jpn</language>
                    <script>Latn</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
            <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
                <title>サマーれげぇ!レインボー</title>
                <status>official</status>
                <text-representation>
                    <language>jpn</language>
                    <script>Jpan</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
        </release-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f/releases', 'artist lookup with releases');
&$v2 ($mech->content, "Validate artist lookup with releases");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f" type="group">
        <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
        <release-list count="2">
            <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
                <title>Summer Reggae! Rainbow</title>
                <status>pseudo-release</status>
                <text-representation>
                    <language>jpn</language>
                    <script>Latn</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
            <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
                <title>サマーれげぇ!レインボー</title>
                <status>official</status>
                <text-representation>
                    <language>jpn</language>
                    <script>Jpan</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
        </release-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');


$mech->get_ok('/ws/2/artist/3088b672-fba9-4b4b-8ae0-dce13babfbb4/releases?inc=discids', 'artist lookup with discids');
&$v2 ($mech->content, "Validate artist lookup with discids");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="group" id="3088b672-fba9-4b4b-8ae0-dce13babfbb4">
        <name>Plone</name><sort-name>Plone</sort-name>
        <release-list count="2">
            <release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221">
                <title>For Beginner Piano</title><status>official</status>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>1999-09-13</date><country>GB</country><barcode>5021603064126</barcode>
                <medium-list count="1">
                    <medium>
                        <position>1</position><format>CD</format>
                        <disc-list count="2">
                            <disc id="4Fzv46Cx17XbCG5hQ1xo6KmQojk-">
                                <sectors>177766</sectors>
                            </disc>
                            <disc id="VkX.hmODEJMV9FhQnxkWzQSX8iE-">
                                <sectors>176980</sectors>
                            </disc>
                        </disc-list>
                        <track-list count="20" />
                    </medium>
                </medium-list>
            </release>
            <release id="dd66bfdd-6097-32e3-91b6-67f47ba25d4c">
                <title>For Beginner Piano</title><status>official</status>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>1999-09-13</date><country>GB</country>
                <medium-list count="1">
                    <medium>
                        <position>1</position><format>Vinyl</format><disc-list count="0" />
                        <track-list count="20" />
                    </medium>
                </medium-list>
            </release>
        </release-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

done_testing;
