package t::MusicBrainz::Server::WebService::Format;
use strict;
use warnings;

use JSON qw( encode_json );
use Test::JSON import => [qw( is_json )];
use Test::More;
use Test::Routine;
use Test::XML::SemanticCompare;

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether the web service understands and properly handles
different ways to request a specific response format (JSON/XML) and properly
rejects invalid requests.

=cut

test 'Webservice request format handling (XML)' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;

    my $Test = Test::Builder->new();

    my $expected = <<~'XML';
        <?xml version="1.0" encoding="UTF-8"?>
        <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
            <artist type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                <name>Distance</name><sort-name>Distance</sort-name>
                <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
            </artist>
        </metadata>
        XML

    $Test->note('Accept: <blank>');
    $mech->default_header('Accept' => '');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    ok($mech->success, 'request successful');
    is_xml_same($mech->content, $expected);

    $Test->note('Accept: */*');
    $mech->default_header('Accept' => '*/*');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    ok($mech->success, 'request successful');
    is_xml_same($mech->content, $expected);

    $Test->note('Accept: application/xml');
    $mech->default_header('Accept' => 'application/xml');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    ok($mech->success, 'request successful');
    is_xml_same($mech->content, $expected);

    $Test->note('fmt=xml');
    $mech->default_header('Accept' => 'application/something-else');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?fmt=xml');
    ok($mech->success, 'request successful');
    is_xml_same($mech->content, $expected);
};

test 'Webservice request format handling (JSON)' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;

    my $Test = Test::Builder->new();

    my $expected = {
        id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
        name => 'Distance',
        'sort-name' => 'Distance',
        country => JSON::null,
        area => JSON::null,
        'begin-area' => JSON::null,
        'end-area' => JSON::null,
        begin_area => JSON::null,
        end_area => JSON::null,
        disambiguation => 'UK dubstep artist Greg Sanders',
        'life-span' => {
            begin => JSON::null,
            end => JSON::null,
            ended => JSON::false,
        },
        type => 'Person',
        'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
        ipis => [],
        isnis => [],
        gender => JSON::null,
        'gender-id' => JSON::null,
    };

    $Test->note('Accept: application/json');
    $mech->default_header('Accept' => 'application/json');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    ok($mech->success, 'request successful');
    is_json($mech->content, encode_json($expected), 'expected contents');

    $Test->note('fmt=json');
    $mech->default_header('Accept' => 'application/something-else');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?fmt=json');
    ok($mech->success, 'request successful');
    is_json($mech->content, encode_json($expected), 'expected contents');
};

test 'Webservice request format handling (errors)' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;

    my $Test = Test::Builder->new();

    my $expected = <<~'XML';
        <?xml version="1.0"?>
        <error>
            <text>Invalid format. Either set an Accept header (recognized mime types are application/json and application/xml), or include a fmt= argument in the query string (valid values for fmt are json and xml).</text>
            <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
        </error>
        XML

    $Test->note('Accept: application/something-else');
    $mech->default_header('Accept' => 'application/something-else');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    is($mech->status, 406, 'server reports 406 - Not Acceptable');
    is_xml_same($mech->content, $expected);

    $Test->note('fmt=unicorn');
    $mech->default_header('Accept' => 'application/json');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?fmt=unicorn');
    is($mech->status, 406, 'server reports 406 - Not Acceptable');
    is_xml_same($mech->content, $expected);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
