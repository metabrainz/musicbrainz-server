use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::RDFa qw( artist_type_ok foaf_mades_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

#my $uri_frag = "/artist/745c079d-374e-4436-9448-da92dedef3ce";
#my $mbid = "20ff3303-4fe2-4a47-a1b6-291e26aa3438";
my $mbid = "745c079d-374e-4436-9448-da92dedef3ce";
my $path = "/artist/" . $mbid;
$mech->get_ok($path, 'fetch artist index page');
artist_type_ok($mech->content, $mbid);
foaf_mades_ok($mech->content, 2);

done_testing;


