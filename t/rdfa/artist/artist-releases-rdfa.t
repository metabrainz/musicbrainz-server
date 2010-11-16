use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::RDFa qw( rdfa_type_ok rdfa_predicate_literal_ok foaf_mades_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;
use RDF::RDFa::Parser;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

my $mbid = "745c079d-374e-4436-9448-da92dedef3ce";
my $path = "/artist/" . $mbid . "/releases";

$mech->get_ok($path, 'fetch artist releases page');

# rdf:type ok
rdfa_type_ok($mech->content, $mbid, "http://purl.org/ontology/mo/MusicArtist");
# number of foaf:mades ok (only one release)
foaf_mades_ok($mech->content, 1);
# foaf:name ok
rdfa_predicate_literal_ok($mech->content, $mbid, "http://xmlns.com/foaf/0.1/name", "Test Artist");


done_testing;


