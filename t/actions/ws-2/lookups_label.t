use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/ws/2/label/b4edce40-090f-4956-b82a-5d9d285da40b', 'basic label lookup');
xml_ok($mech->content);

my $diff = XML::SemanticDiff->new;

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label>
        <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
        <life-span><begin>1995</begin></life-span>
    </label>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=aliases', 'label lookup, inc=aliases');
xml_ok($mech->content);

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label>
        <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
        <life-span><begin>1995</begin></life-span>
        <alias-list count="1"><alias>Planet µ</alias></alias-list>
    </label>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/label/b4edce40-090f-4956-b82a-5d9d285da40b/releases?inc=media', 'label lookup with releases, inc=media');
xml_ok($mech->content);

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label>
        <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
        <life-span><begin>1995</begin></life-span>
        <release-list count="2">
            <release id="adcf7b48-086e-48ee-b420-1001f88d672f">
                <title>My Demons</title><status>official</status>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2007-01-29</date><country>GB</country>
                <medium-list count="1">
                    <medium>
                        <position>1</position><format>CD</format><track-list count="24" />
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
                        <position>1</position><format>CD</format><track-list count="18" />
                    </medium>
                    <medium>
                        <title>Chestplate Singles</title><position>2</position>
                        <format>CD</format><track-list count="18" />
                    </medium>
                </medium-list>
            </release>
        </release-list>
    </label>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
