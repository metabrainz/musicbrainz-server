package t::MusicBrainz::Server::Controller::WS::2::LookupInstrument;
use utf8;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use Test::XML::SemanticCompare qw( is_xml_same );
use MusicBrainz::Server::Test ws_test => {
    version => 2,
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;
$mech->default_header('Accept' => 'application/xml');

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

$c->sql->do(<<~'SQL');
    UPDATE instrument_alias
    SET type = 1, locale = 'fr', primary_for_locale = true
    WHERE id = 1;
    SQL

$mech->get('/ws/2/instrument/3590521b-8c97-4f4b-b1bb-5f68d3663d8a?inc=coffee');
is($mech->status, HTTP_BAD_REQUEST);
is_xml_same($mech->content, q{<?xml version="1.0"?>
<error>
  <text>coffee is not a valid inc parameter for the instrument resource.</text>
  <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
</error>});

ws_test 'basic instrument lookup',
    '/instrument/3590521b-8c97-4f4b-b1bb-5f68d3663d8a' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <instrument type="Wind instrument" type-id="876464a8-e74f-3f40-9bd3-637d2b1743ae" id="3590521b-8c97-4f4b-b1bb-5f68d3663d8a">
        <name>English horn</name>
    </instrument>
</metadata>';

ws_test 'instrument lookup, inc=aliases',
    '/instrument/3590521b-8c97-4f4b-b1bb-5f68d3663d8a?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <instrument type="Wind instrument" type-id="876464a8-e74f-3f40-9bd3-637d2b1743ae" id="3590521b-8c97-4f4b-b1bb-5f68d3663d8a">
        <name>English horn</name>
        <alias-list count="2">
            <alias sort-name="English horn">English horn</alias>
            <alias sort-name="cor anglais" primary="primary" locale="fr" type="Instrument name" type-id="2322fc94-fbf3-3c09-b23c-aa5ec8d14fcd">cor anglais</alias>
        </alias-list>
    </instrument>
</metadata>';

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
