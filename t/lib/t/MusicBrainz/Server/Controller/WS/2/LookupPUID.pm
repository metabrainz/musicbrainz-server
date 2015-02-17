package t::MusicBrainz::Server::Controller::WS::2::LookupPUID;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};
use XML::SemanticDiff;

test all => sub {

my $test = shift;
my $c = $test->c;
my $v2 = schema_validator;
my $diff = XML::SemanticDiff->new;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

my $res = $test->mech->get('/ws/2/puid/cdec3fe2-0473-073c-3cbb-bfb0c01a87ff');
is($res->code, HTTP_NOT_FOUND);

$res = $test->mech->get('/ws/2/puid/cdec3fe2-0473-073c-3cbb-bfb0c01a87ff?inc=releases');
is($res->code, HTTP_NOT_FOUND);

};

1;

