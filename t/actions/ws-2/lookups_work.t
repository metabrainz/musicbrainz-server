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

$mech->get_ok('/ws/2/work/1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f', 'basic work lookup');
&$v2 ($mech->content, "Validate basic work lookup");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <work id="1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f">
        <title>Milky Way 〜君の歌〜</title>
    </work>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/work/1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f?inc=recording-rels', 'work lookup with recording relationships');
&$v2 ($mech->content, "Validate work lookup with recording relationships");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <work id="1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f">
        <title>Milky Way 〜君の歌〜</title>
        <relation-list target-type="recording">
            <relation type="performance">
                <target>1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f</target>
                <direction>backward</direction>
                <recording id="1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f">
                    <title>Milky Way 〜君の歌〜</title><length>203840</length>
                </recording>
            </relation>
        </relation-list>
    </work>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
