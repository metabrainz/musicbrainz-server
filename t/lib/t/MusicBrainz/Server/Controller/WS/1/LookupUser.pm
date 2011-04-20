package t::MusicBrainz::Server::Controller::WS::1::LookupUser;
use Test::Routine;
use Test::More;

with 't::Context', 't::Mechanize';

use utf8;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 1
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;
my $diff = XML::SemanticDiff->new;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password)
    VALUES (1, 'editor', 'password'), (2, 'other editor', 'password');
EOSQL

subtest 'Must authenticate' => sub {
    $mech->get('/ws/1/user/?type=xml&name=editor');
    is ($mech->status, 401, 'Tags rejected without authentication');
};

subtest 'Can view own user' => sub {
    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');
    $mech->get_ok('/ws/1/user/?type=xml&name=editor');
    my $expect = <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" xmlns:ext="http://musicbrainz.org/ns/ext-1.0#">
  <ext:user-list>
    <ext:user type="">
      <name>editor</name>
      <ext:nag show="false"/>
    </ext:user>
  </ext:user-list>
</metadata>
EOXML

    xml_ok ($mech->content);
    is($diff->compare($mech->content, $expect), 0, 'result ok');
};

subtest 'Cannot view other users' => sub {
    $mech->get('/ws/1/user/?type=xml&name=other%20editor');
    is ($mech->status, 403);
};

};

1;

