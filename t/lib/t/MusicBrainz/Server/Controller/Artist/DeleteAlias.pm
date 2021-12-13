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
$mech->submit_form(
    with_fields => {
        'confirm.edit_note' => q(Some edit note since it's required)
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
    sort_name => 'Test Alias',
    primary_for_locale => 0,
    locale => undef,
    begin_date => {
        year => 2000,
        month => 1,
        day => 1
    },
    end_date => {
        year => 2005,
        month => 5,
        day => 6
    },
    ended => 1,
    type_id => undef
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content);
$mech->content_contains('Test Artist', '..has artist name');
$mech->content_contains('Test Alias', '..has alias name');

};

1;
