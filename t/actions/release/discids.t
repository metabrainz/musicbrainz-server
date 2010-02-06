use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/discids');
xml_ok($mech->content);
$mech->content_like(qr{tLGBAiCflG8ZI6lFcOt87vXjEcI-});

$mech->get_ok('/release/lookup/?toc=1+10+323860+182+36697+68365+94047+125922+180342+209172+245422+275887+300862');

done_testing;
