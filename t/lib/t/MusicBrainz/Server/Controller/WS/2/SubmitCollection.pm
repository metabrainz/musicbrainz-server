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
$mech->default_header("Accept" => "application/xml");

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

my $collection = $c->model('Collection')->get_by_gid('1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5');
my $release = $c->model('Release')->get_by_gid('a84b9fea-aee9-4e1f-b5a2-a5a23c673688');

my $uri = '/ws/2/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5/releases/'.
    $release->gid . '?client=test-1.0';

subtest 'Add releases to collection' => sub {
    $mech->put($uri);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant PUT without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'the-anti-kuno', 'notreally');

    $mech->put_ok($uri);
    note($mech->content);
    xml_ok($mech->content);

    ok($c->model('Collection')->contains_entity('release', $collection->id, $release->id));
};

$test->_clear_mech;
$mech = $test->mech;

subtest 'Remove releases from collection' => sub {
    my $req = DELETE $uri;
    $mech->request($req);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'the-anti-kuno', 'notreally');

    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    ok(!$c->model('Collection')->contains_entity('release', $collection->id, $release->id));
};

};

1;
