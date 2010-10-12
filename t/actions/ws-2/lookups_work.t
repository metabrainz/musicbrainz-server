use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => { version => 2 };
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $v2 = schema_validator;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my $diff = XML::SemanticDiff->new;

ws_test 'basic work lookup',
    '/work/1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <work id="1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f">
        <title>Milky Way 〜君の歌〜</title>
    </work>
</metadata>';

ws_test 'work lookup with recording relationships',
    '/work/1272ecf4-fc8d-4d10-889c-afe6a1fa2d8f?inc=recording-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
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

done_testing;
