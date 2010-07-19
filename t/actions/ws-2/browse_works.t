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

$mech->get_ok('/ws/2/work?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&limit=5', 'browse works via artist (first page)');
&$v2 ($mech->content, "Validate browse works via artist (first page)");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <work-list count="10">
        <work id="7e379a1d-f2bc-47b8-964e-00723df34c8a">
            <title>Be Rude to Your School</title>
        </work>
        <work id="6f9c8c32-3aae-4dad-b023-56389361cf6b">
            <title>Bibi Plone</title>
        </work>
        <work id="4f392ffb-d3df-4f8a-ba74-fdecbb1be877">
            <title>Busy Working</title>
        </work>
        <work id="791d9b27-ae1a-4295-8943-ded4284f2122">
            <title>Marbles</title>
        </work>
        <work id="44704dda-b877-4551-a2a8-c1f764476e65">
            <title>On My Bus</title>
        </work>
    </work-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

$mech->get_ok('/ws/2/work?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&limit=5&offset=5', 'browse works via artist (second page)');
&$v2 ($mech->content, "Validate browse works via artist (second page)");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <work-list count="10" offset="5">
        <work id="6e89c516-b0b6-4735-a758-38e31855dcb6">
            <title>Plock</title>
        </work>
        <work id="25e9ae0f-8b7d-4230-9cde-9a07f7680e4a">
            <title>Press a Key</title>
        </work>
        <work id="a8614bda-42dc-43c7-ac5f-4067acb6f1c5">
            <title>Summer Plays Out</title>
        </work>
        <work id="dc891eca-bf42-4103-8682-86068fe732a5">
            <title>The Greek Alphabet</title>
        </work>
        <work id="8920288e-7541-48a7-b23b-f80447c8b1ab">
    <title>Top &amp; Low Rent</title>
        </work>
    </work-list>
</metadata>';

is ($diff->compare ($mech->content, $expected), 0, 'result ok');

done_testing;
