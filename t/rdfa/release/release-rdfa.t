use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::RDFa qw( rdfa_type_ok rdfa_predicate_literal_ok rdfa_predicate_ok);
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# load t/sql/release.sql
MusicBrainz::Server::Test->prepare_test_database($c, '+release');

# from t/sql/release.sql
my $release_mbid = "7a906020-72db-11de-8a39-0800200c9a66";
my $release_name = 'Release #2';
my $release_type = "http://purl.org/ontology/mo/Release";
my $path = "/release/" . $release_mbid;
my $maker_uri = 'http://localhost/artist/a9d99e40-72d7-11de-8a39-0800200c9a66#_';

$mech->get_ok($path, 'fetch release index page');
# check rdf:type
rdfa_type_ok($mech->content, $release_mbid, $release_type);
# check dct:title
rdfa_predicate_literal_ok($mech->content, 
                          $release_mbid, 
                          "http://purl.org/dc/terms/title", 
                          $release_name);
rdfa_predicate_ok($mech->content, $release_mbid, "http://xmlns.com/foaf/0.1/maker", $maker_uri);

done_testing;



