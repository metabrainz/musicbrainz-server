use strict;
use warnings;

use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/annotation/1', 'Fetch an annotation page');
$mech->content_contains('Test annotation 1', '..has annotation');
$mech->content_contains('More annotation', '..has annotation');

done_testing;
