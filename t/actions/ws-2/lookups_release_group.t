use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/ws/2/release/b84625af-6229-305f-9f1b-59c0185df016', 'basic release lookup');
xml_ok($mech->content);

my $diff = XML::SemanticDiff->new;

my $expected  ='<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="single" id="b84625af-6229-305f-9f1b-59c0185df016">
        <title>サマーれげぇ!レインボー</title>
    </release-group>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
