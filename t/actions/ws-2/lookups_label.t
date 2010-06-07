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

done_testing;
