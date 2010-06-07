use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/ws/2/artist/f26c72d3-e52c-467b-b651-679c73d8e1a7', 'basic artist lookup');
xml_ok($mech->content);

my $diff = XML::SemanticDiff->new;

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="group" id="f26c72d3-e52c-467b-b651-679c73d8e1a7">
        <name>!!!</name><sort-name>!!!</sort-name>
        <life-span><begin>1996</begin></life-span>
    </artist>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/artist/f26c72d3-e52c-467b-b651-679c73d8e1a7?inc=aliases', 'artist lookup, inc=aliases');
xml_ok($mech->content);

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

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
