use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/ws/2/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7', 'basic recording lookup');
xml_ok($mech->content);

my $diff = XML::SemanticDiff->new;

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title><length>296026</length>
    </recording>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');


$mech->get_ok('/ws/2/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7/releases', 'recording lookup with releases');
xml_ok($mech->content);

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title><length>296026</length>
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
    </recording>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
