use strict;
use Test::More;

use MusicBrainz::Server::Test qw( xml_ok );

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-');
xml_ok($mech->content);
$mech->content_like(qr{Aerial});
$mech->content_like(qr{Kate Bush});

done_testing;
