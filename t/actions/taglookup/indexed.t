use utf8;
use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/taglookup?artist=中島+美嘉&release=love', 'performed tag lookup');

$mech->content_contains('中島美嘉', 'has correct artist result');
$mech->content_contains('LOVE', 'has correct release result');
$mech->content_contains('Make a donation now', 'has nag screen');

done_testing;
