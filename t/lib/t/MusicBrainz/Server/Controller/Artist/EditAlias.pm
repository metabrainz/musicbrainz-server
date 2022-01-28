package t::MusicBrainz::Server::Controller::Artist::EditAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

# Test deleting aliases
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/alias/1/edit');
$mech->submit_form(
    with_fields => {
        'edit-alias.name' => 'Edited alias'
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::EditAlias');
is_deeply($edit->data, {
    entity => {
        id => 3,
        name => 'Test Artist'
    },
    alias_id  => 1,
    new => {
        name => 'Edited alias',
    },
    old => {
        name => 'Test Alias',
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content);
$mech->content_contains('Test Artist', '..has artist name');
$mech->content_contains('Test Alias', '..has old alias name');
$mech->content_contains('Edited alias', '..has new alias name');

# A sortname isn't required (MBS-6896)
($edit) = capture_edits {
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/alias/1/edit');
    $mech->submit_form(
        with_fields => {
            'edit-alias.name' => 'Edit #2',
            'edit-alias.sort_name' => '',
        });
} $c;

isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::EditAlias');
is($edit->data->{new}{sort_name}, 'Edit #2', 'sort_name defaults to name');

};

1;
