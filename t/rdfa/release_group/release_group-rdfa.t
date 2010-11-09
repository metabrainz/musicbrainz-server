use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::RDFa qw( rdfa_type_ok rdfa_predicate_literal_ok rdfa_predicate_ok print_triples );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# load t/sql/releasegroup.sql
MusicBrainz::Server::Test->prepare_test_database($c, '+releasegroup');

# from t/sql/releasegroup.sql 
my $mbid = '7b5d22d0-72d7-11de-8a39-0800200c9a66';
my $name = 'Release Group';
my $type = "http://purl.org/ontology/mo/SignalGroup";
my $path = "/release-group/" . $mbid;
my $maker_uri = 'http://localhost/artist/a9d99e40-72d7-11de-8a39-0800200c9a66#_';


$mech->get_ok($path, 'fetch release-group index page');
# correct rdf:type
rdfa_type_ok($mech->content, $mbid, $type);
# do we see the dct:title ??
rdfa_predicate_literal_ok($mech->content, $mbid, "http://purl.org/dc/terms/title", $name);
# have we got the right foaf:maker ??
rdfa_predicate_ok($mech->content, $mbid, "http://xmlns.com/foaf/0.1/maker", $maker_uri);
# print all triple for a quick look
print_triples($mech->content);

done_testing;
