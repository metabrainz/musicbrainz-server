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

$mech->get_ok('/ws/2/release-group/b84625af-6229-305f-9f1b-59c0185df016', 'basic release group lookup');
&$v2 ($mech->content, "Validate basic release group lookup");

my $expected  ='<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="single" id="b84625af-6229-305f-9f1b-59c0185df016">
        <title>サマーれげぇ!レインボー</title>
    </release-group>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2/releases', 'release group lookup with releases');
&$v2 ($mech->content, "Validate release group with releases");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="album" id="56683a0b-45b8-3664-a231-5b68efe2e7e2">
        <title>Repercussions</title>
        <release-list count="1">
            <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134">
                <title>Repercussions</title><status>official</status>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2008-11-17</date><country>GB</country>
            </release>
        </release-list>
    </release-group>
</metadata>';

$mech->get_ok('/ws/2/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2/artists', 'release group lookup with artists');
&$v2 ($mech->content, "Validate release group with artists");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="album" id="56683a0b-45b8-3664-a231-5b68efe2e7e2">
        <title>Repercussions</title>
        <artist-credit>
            <name-credit>
                <artist type="person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                    <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
                </artist>
            </name-credit>
        </artist-credit>
    </release-group>
</metadata>';


is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
