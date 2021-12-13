package t::MusicBrainz::Server::Controller::Artist::OpenEdits;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test editing artists
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
html_ok($mech->content);
$mech->submit_form(
    with_fields => {
        'edit-artist.name' => 'history viewing',
        'edit-artist.rename_artist_credit' => undef
    }
);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Edit');

is ($edit->auto_edit, 0, 'is not an auto edit');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/open_edits',
              'fetch artist edit history');
$mech->content_contains('/edit/' . $edit->id, 'contains open edit id');

};

1;
