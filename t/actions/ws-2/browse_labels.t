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

$mech->get_ok('/ws/2/label?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7&inc=artist-rels+label-rels', 'browse labels via release');
&$v2 ($mech->content, "Validate browse labels via release");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label-list count="1">
        <label>
            <name>rhythm zone</name><sort-name>rhythm zone</sort-name><country>JP</country>
            <relation-list target-type="label">
                <relation type="label_ownership">
                    <target>168f48c8-057e-4974-9600-aa9956d21e1a</target><direction>backward</direction>
                    <label>
                        <name>avex trax</name><sort-name>avex trax</sort-name>
                    </label>
                </relation>
            </relation-list>
        </label>
    </label-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
