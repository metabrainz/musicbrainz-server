use strict;
use warnings;

use Test::More;

use MusicBrainz::Server::Test qw( xml_ok );

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/isrc/DEE250800230');
xml_ok($mech->content);
$mech->content_contains('King of the Mountain');
$mech->content_contains('Kate Bush');

$mech->get('/isrc/DEE250812345');
is($mech->status(), 404);

$mech->get('/isrc/xxx');
is($mech->status(), 404);

done_testing;
