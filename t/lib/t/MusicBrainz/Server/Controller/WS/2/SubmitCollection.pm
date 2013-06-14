package t::MusicBrainz::Server::Controller::WS::2::SubmitCollection;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Status qw( :constants );
use HTTP::Request::Common qw( DELETE );
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
$mech->default_header ("Accept" => "application/xml");

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478');
INSERT INTO editor_collection (id, gid, editor, name, public)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 'my collection', FALSE);
EOSQL

my $collection = $c->model('Collection')->get_first_collection(1);
my $release = $c->model('Release')->get_by_gid('0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e');

my $uri = '/ws/2/collection/f34c079d-374e-4436-9448-da92dedef3ce/releases/'.
    $release->gid . '?client=test-1.0';

subtest 'Add releases to collection' => sub {
    $mech->put($uri);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant PUT without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    $mech->put_ok($uri);
    note($mech->content);
    xml_ok($mech->content);

    ok($c->model('Collection')->check_release($collection, $release->id));
};

$test->_clear_mech;
$mech = $test->mech;

subtest 'Remove releases from collection' => sub {
    my $req = DELETE $uri;
    $mech->request($req);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    ok(!$c->model('Collection')->check_release($collection, $release->id));
};

};

1;

