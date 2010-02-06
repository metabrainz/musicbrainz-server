use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/aliases', 'get label aliases');
xml_ok($mech->content);
$mech->content_contains('Test Label Alias', 'has the label alias');

done_testing;
