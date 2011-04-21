package t::MusicBrainz::Server::Controller::Artist::DeleteAlias;
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

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

# Test deleting aliases
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/alias/1/delete');
my $response = $mech->submit_form(
    with_fields => {
        'confirm.edit_note' => ''
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::DeleteAlias');
is_deeply($edit->data, {
    entity    => {
        id => 3,
        name => 'Test Artist'
    },
    alias_id  => 1,
    name      => 'Test Alias',
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content, '..valid xml');
$mech->content_contains('Test Artist', '..has artist name');
$mech->content_contains('Test Alias', '..has alias name');

};

1;
