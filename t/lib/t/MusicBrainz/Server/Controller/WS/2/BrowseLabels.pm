package t::MusicBrainz::Server::Controller::WS::2::BrowseLabels;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use XML::SemanticDiff;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $v2 = schema_validator;
my $diff = XML::SemanticDiff->new;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'browse labels via release',
    '/label?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label-list count="1">
        <label type="Original Production" id="72a46579-e9a0-405a-8ee1-e6e6b63b8212">
            <name>rhythm zone</name>
            <sort-name>rhythm zone</sort-name>
            <country>JP</country>
            <area id="2db42837-c832-3c27-b4a3-08198f75693c">
                <name>Japan</name>
                <sort-name>Japan</sort-name>
                <iso-3166-1-code-list>
                    <iso-3166-1-code>JP</iso-3166-1-code>
                </iso-3166-1-code-list>
            </area>
        </label>
    </label-list>
</metadata>';

};

1;

