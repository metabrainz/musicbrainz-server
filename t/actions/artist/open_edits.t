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

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-artist.name' => 'history viewing',
    }
);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
$mech->get_ok("/artist/745c079d-374e-4436-9448-da92dedef3ce/open_edits",
              'fetch artist edit history');
$mech->content_contains('/edit/' . $edit->id, 'contains open edit id');

done_testing;
