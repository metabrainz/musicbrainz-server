package t::MusicBrainz::Server::Controller::Label::DeleteAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/alias/1/delete');
$mech->submit_form(
    with_fields => {
        'confirm.edit_note' => 'This is required now.'
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::DeleteAlias');
is_deeply($edit->data, {
    entity => {
        id => 2,
        name => 'Warp Records'
    },
    alias_id  => 1,
    name      => 'Test Label Alias',
    sort_name => 'Test Label Alias',
    begin_date => {
        year => undef,
        month => undef,
        day => undef
    },
    end_date => {
        year => undef,
        month => undef,
        day => undef
    },
    ended => 0,
    type_id => 1,
    locale => undef,
    primary_for_locale => 0
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content);
$mech->content_contains('Warp Records', '..has label name');
$mech->content_contains('Test Label Alias', '..has alias name');

};

1;
