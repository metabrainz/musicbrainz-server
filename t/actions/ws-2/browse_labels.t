use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $v2 = schema_validator;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my $diff = XML::SemanticDiff->new;

$mech->get_ok('/ws/2/label?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7', 'browse labels via release');
&$v2 ($mech->content, "Validate browse labels via release");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label-list count="1">
        <label type="original production" id="72a46579-e9a0-405a-8ee1-e6e6b63b8212">
            <name>rhythm zone</name><sort-name>rhythm zone</sort-name><country>JP</country>
        </label>
    </label-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
