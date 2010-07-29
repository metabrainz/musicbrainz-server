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

$mech->get_ok('/ws/2/release-group?release=adcf7b48-086e-48ee-b420-1001f88d672f&inc=artist-credits+tags+ratings', 'browse release group via release');
&$v2 ($mech->content, "Validate browse release-group via release");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group-list count="1">
        <release-group type="album" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
            <title>My Demons</title>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                        <name>Distance</name>
                    </artist>
                </name-credit>
            </artist-credit>
            <tag-list>
                <tag count="2"><name>dubstep</name></tag>
                <tag count="1"><name>electronic</name></tag>
                <tag count="1"><name>grime</name></tag>
            </tag-list>
        </release-group>
    </release-group-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/release-group?artist=472bc127-8861-45e8-bc9e-31e8dd32de7a&inc=artist-credits+tags+ratings', 'browse release group via artist');
&$v2 ($mech->content, "Validate browse release-group via artist");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group-list count="2">
        <release-group type="album" id="22b54315-6e51-350b-bb34-e6e16f7688bd">
            <title>My Demons</title>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                        <name>Distance</name>
                    </artist>
                </name-credit>
            </artist-credit>
            <tag-list>
                <tag count="2"><name>dubstep</name></tag>
                <tag count="1"><name>electronic</name></tag>
                <tag count="1"><name>grime</name></tag>
            </tag-list>
        </release-group>
        <release-group type="album" id="56683a0b-45b8-3664-a231-5b68efe2e7e2">
            <title>Repercussions</title>
            <artist-credit>
                <name-credit>
                    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                        <name>Distance</name>
                    </artist>
                </name-credit>
            </artist-credit>
            <tag-list />
        </release-group>
    </release-group-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
