#!/usr/bin/perl
use strict;
use Test::More tests => 39;

BEGIN {
    use MusicBrainz::Server::Context;
    use MusicBrainz::Server::Test;
    my $c = MusicBrainz::Server::Context->new();
    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_server();
}

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/artist/745c079d-374e-4436-9448-da92dedef3ce", 'fetch artist index page');
$mech->title_like(qr/Test Artist/, 'title has artist name');
$mech->content_like(qr/Test Artist/, 'content has artist name');
$mech->content_like(qr/Artist, Test/, 'content has artist sort name');
$mech->content_like(qr/Yet Another Test Artist/, 'disambiguation comments');
$mech->content_like(qr/2008-01-02/, 'has start date');
$mech->content_like(qr/2009-03-04/, 'has end date');
$mech->content_like(qr/Person/, 'has artist type');
$mech->content_like(qr/Male/, 'has gender');
$mech->content_like(qr/United Kingdom/, 'has country');
$mech->content_like(qr/Test annotation 1/, 'has annotation');
$mech->content_unlike(qr/More annotation/, 'only display summary');

# Header links
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce/works', 'link to artist works');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce/recordings', 'link to artist recordings');

# Basic test for release groups
$mech->content_like(qr/Test RG 1/, 'release group 1');
$mech->content_like(qr{/release-group/ecc33260-454c-11de-8a39-0800200c9a66}, 'release group 1');

$mech->content_like(qr/Test RG 2/, 'release group 2');
$mech->content_like(qr{/release-group/7348f3a0-454e-11de-8a39-0800200c9a66}, 'release group 2');

# Test /artist/gid/works
$mech->get_ok('/artist/a45c079d-374e-4436-9448-da92dedef3cf/works', 'get ABBA page');
$mech->title_like(qr/ABBA/, 'title has ABBA');
$mech->title_like(qr/works/i, 'title indicates works listing');
$mech->content_contains('Dancing Queen');
$mech->content_contains('/work/745c079d-374e-4436-9448-da92dedef3ce', 'has a link to the work');

# Test /artist/gid/recordings
$mech->get_ok('/artist/a45c079d-374e-4436-9448-da92dedef3cf/recordings', 'get ABBA page');
$mech->title_like(qr/ABBA/, 'title has ABBA');
$mech->title_like(qr/recordings/i, 'title indicates recordings listing');
$mech->content_contains('Dancing Queen');
$mech->content_contains('2:03');
$mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'has a link to the recording');

# Test /artist/gid/releases
$mech->get_ok('/artist/a45c079d-374e-4436-9448-da92dedef3cf/releases', 'get ABBA page');
$mech->title_like(qr/ABBA/, 'title has ABBA');
$mech->title_like(qr/releases/i, 'title indicates releases listing');
$mech->content_contains('Arrival', 'release title');
$mech->content_contains('2009-05-08', 'release date');
$mech->content_contains('/release/f34c079d-374e-4436-9448-da92dedef3ce', 'has a link to the release');

# Test aliases
$mech->get_ok('/artist/945c079d-374e-4436-9448-da92dedef3cf/aliases', 'get artist aliases');
$mech->content_contains('Test Alias', 'has the artist alias');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce', 'get artist aliases');
$mech->content_unlike(qr/Test Alias/, 'other artist pages do not have the alias');
