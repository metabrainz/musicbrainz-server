package t::MusicBrainz::Server::Controller::WS::2::LookupSeries;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use Test::XML::SemanticCompare;
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;
$mech->default_header('Accept' => 'application/xml');

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

$mech->get('/ws/2/series/d977f7fd-96c9-4e3e-83b5-eb484a9e6582?inc=coffee');
is($mech->status, 400);
is_xml_same($mech->content, q{<?xml version="1.0"?>
<error>
  <text>coffee is not a valid inc parameter for the series resource.</text>
  <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
</error>});

ws_test 'basic series lookup',
    '/series/d977f7fd-96c9-4e3e-83b5-eb484a9e6582' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <series type="Catalogue" type-id="49482ff0-fc9e-3b8c-a2d0-30e84d9df002" id="d977f7fd-96c9-4e3e-83b5-eb484a9e6582">
        <name>Bach-Werke-Verzeichnis</name>
    </series>
</metadata>';

ws_test 'series lookup, inc=aliases',
    '/series/d977f7fd-96c9-4e3e-83b5-eb484a9e6582?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <series type="Catalogue" type-id="49482ff0-fc9e-3b8c-a2d0-30e84d9df002" id="d977f7fd-96c9-4e3e-83b5-eb484a9e6582">
        <name>Bach-Werke-Verzeichnis</name>
        <alias-list count="1">
            <alias sort-name="BWV">BWV</alias>
        </alias-list>
    </series>
</metadata>';

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
