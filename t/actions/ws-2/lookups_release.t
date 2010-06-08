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

$mech->get_ok('/ws/2/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7/artists', 'release lookup with artists');
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
                    <life-span>
                        <begin>1998</begin>
                    </life-span>
                </artist>
            </name-credit>
        </artist-credit>
    </release>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
