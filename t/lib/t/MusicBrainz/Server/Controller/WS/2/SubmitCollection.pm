package t::MusicBrainz::Server::Controller::WS::2::SubmitCollection;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Status qw( :constants );
use XML::SemanticDiff;
use XML::XPath;

use MusicBrainz::Server::Test qw( xml_ok schema_validator xml_post );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $v2 = schema_validator;
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password)
    VALUES (1, 'new_editor', 'password');
INSERT INTO editor_collection (id, gid, editor, name, public)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 'my collection', FALSE);
EOSQL

my $collection = $c->model('Collection')->get_first_collection(1);
my $release = $c->model('Release')->get_by_gid('0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e');

subtest 'Add releases to collection' => sub {
    my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <add>
    <release id="' . $release->gid . '" />
  </add>
</metadata>';

    my $req = xml_post('/ws/2/collection/f34c079d-374e-4436-9448-da92dedef3ce?client=test-1.0', $content);

    $mech->request($req);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    $mech->request($req);
    is($mech->status, HTTP_OK);
    note($mech->content);
    xml_ok($mech->content);

    ok($c->model('Collection')->check_release($collection, $release->id));
};

$test->_clear_mech;
$mech = $test->mech;

subtest 'Remove releases from collection' => sub {
    my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <remove>
    <release id="' . $release->gid . '" />
  </remove>
</metadata>';

    my $req = xml_post('/ws/2/collection/f34c079d-374e-4436-9448-da92dedef3ce?client=test-1.0', $content);

    $mech->request($req);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    $c->model('Collection')->check_release($collection, $release->id);

    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    ok(!$c->model('Collection')->check_release($collection, $release->id));
};

};

1;

