use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test editing artists
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

# Test tagging
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tag');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'tag.tags' => 'World Music, Jazz',
    }
);
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
xml_ok($mech->content);

$mech->content_contains('world music');
$mech->content_contains('jazz');

done_testing;
