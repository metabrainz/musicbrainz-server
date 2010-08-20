use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::RDFa qw( artist_type_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;
use RDF::RDFa::Parser;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

my $uri_frag = "/artist/745c079d-374e-4436-9448-da92dedef3ce";
$mech->get_ok($uri_frag, 'fetch artist index page');
artist_type_ok($mech->content, $uri_frag);

done_testing;


