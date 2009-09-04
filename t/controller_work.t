#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 14;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce");
$mech->content_like(qr/Dancing Queen/, 'work title');
$mech->content_like(qr/ABBA/, 'artist credit');
$mech->content_like(qr/Composition/, 'work type');
$mech->content_like(qr{/work/745c079d-374e-4436-9448-da92dedef3ce}, 'link back to work');
$mech->content_like(qr{/artist/a45c079d-374e-4436-9448-da92dedef3cf}, 'link to ABBA');
$mech->content_like(qr/T-000.000.001-0/, 'iswc');
$mech->content_like(qr{Test annotation 6}, 'annotation');

# Missing
$mech->get('/work/dead079d-374e-4436-9448-da92dedef3ce');
is($mech->status(), 404);

# Invalid UUID
$mech->get('/work/xxxx079d-374e-4436-9448-da92dedef3ce');
is($mech->status(), 404);

# Test tags
$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/tags");
$mech->content_like(qr{musical});
ok($mech->find_link(url_regex => qr{/tag/musical}), 'link to the "musical" tag');

# Test ratings
$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/ratings");
