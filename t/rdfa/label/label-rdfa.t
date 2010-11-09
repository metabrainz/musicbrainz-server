use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::RDFa qw( rdfa_type_ok rdfa_predicate_literal_ok rdfa_predicate_ok print_triples );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# load t/sql/label.sql
MusicBrainz::Server::Test->prepare_test_database($c, '+label');

# from t/sql/label.sql 
my $mbid = '46f0f4cd-8aab-4b33-b698-f459faf64190';
my $name = 'Warp Records';
my $type = "http://purl.org/ontology/mo/Label";
my $path = "/label/" . $mbid;

$mech->get_ok($path, 'fetch release-group index page');
# correct rdf:type
rdfa_type_ok($mech->content, $mbid, $type);
# do we see the dct:title ??
rdfa_predicate_literal_ok($mech->content, $mbid, "http://purl.org/dc/terms/title", $name);
rdfa_predicate_literal_ok($mech->content, $mbid, "http://www.w3.org/2000/01/rdf-schema#label", $name);
# print all triple for a quick look
print_triples($mech->content);

done_testing;
