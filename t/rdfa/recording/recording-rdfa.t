use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::RDFa qw( rdfa_type_ok rdfa_predicate_literal_ok rdfa_predicate_ok print_triples );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# load t/sql/add_track.sql
MusicBrainz::Server::Test->prepare_test_database($c, '+add_track');

# from t/sql/add_track.sql
my $mbid = '54b9d183-7dab-42ba-94a3-7388a66604b8';
my $name = 'First Track';
my $type = "http://purl.org/ontology/mo/Signal";
my $path = "/recording/" . $mbid;
my $maker_uri = 'http://localhost/artist/945c079d-374e-4436-9448-da92dedef3cf#_';
#my $maker_uri = '945c079d-374e-4436-9448-da92dedef3cf';

$mech->get_ok($path, 'fetch recording index page');
# correct rdf:type
rdfa_type_ok($mech->content, $mbid, $type);
# do we see the dct:title ??
rdfa_predicate_literal_ok($mech->content, $mbid, "http://purl.org/dc/terms/title", $name);
# have we got the right foaf:maker ??
rdfa_predicate_ok($mech->content, $mbid, "http://xmlns.com/foaf/0.1/maker", $maker_uri);
# print all triple for a quick look
print_triples($mech->content);

done_testing;



