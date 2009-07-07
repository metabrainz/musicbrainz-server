#!/usr/bin/perl
use strict;
use Test::More tests => 18;

BEGIN {
    use MusicBrainz::Server::Context;
    use MusicBrainz::Server::Test;
    my $c = MusicBrainz::Server::Test->create_test_context();
    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_server();
}

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/label/46f0f4cd-8aab-4b33-b698-f459faf64190", 'fetch label index');
$mech->title_like(qr/Warp Records/, 'title has label name');
$mech->content_like(qr/Warp Records/, 'content has label name');
$mech->content_like(qr/Sheffield based electronica label/, 'disambiguation comments');
$mech->content_like(qr/1989-02-03/, 'has start date');
$mech->content_like(qr/2008-05-19/, 'has end date');
$mech->content_like(qr/United Kingdom/, 'has country');
$mech->content_like(qr/Production/, 'has label type');
$mech->content_like(qr/Test annotation 2/, 'has annotation');

# Check releases
$mech->content_like(qr/Arrival/, 'has release title');
$mech->content_like(qr/ABC-123/, 'has catalog of first release');
$mech->content_like(qr/ABC-123-X/, 'has catalog of second release');
$mech->content_like(qr/2009-05-08/, 'has release date');
$mech->content_like(qr{GB}, 'has country in release list');
$mech->content_like(qr{/release/f34c079d-374e-4436-9448-da92dedef3ce}, 'links to correct release');

# Test aliases
$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/aliases', 'get label aliases');
$mech->content_contains('Test Label Alias', 'has the label alias');

# Test ratings
$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/ratings', 'get label ratings');
