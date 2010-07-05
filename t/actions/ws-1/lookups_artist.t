use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use XML::SemanticCompare;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $v1 = schema_validator (1);
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my $diff = XML::SemanticDiff->new;

$mech->get_ok('/ws/1/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a', 'basic artist lookup');
&$v1 ($mech->content, "Validate basic artist lookup");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person">
        <name>Distance</name><sort-name>Distance</sort-name>
        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

done_testing;
