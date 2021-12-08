package t::MusicBrainz::Server::Controller::Label::AddAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/add-alias');
$mech->submit_form(
    with_fields => {
        'edit-alias.name' => 'An alias',
        'edit-alias.sort_name' => 'An alias sort name'
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::AddAlias');
is_deeply($edit->data, {
    entity => {
        id => 2,
        name => 'Warp Records'
    },
    name => 'An alias',
    sort_name => 'An alias sort name',
    locale => undef,
    primary_for_locale => 0,
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
    type_id => undef,
    ended => 0
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content);

$mech->content_contains('Warp Records', '..contains label name');
$mech->content_contains('/label/46f0f4cd-8aab-4b33-b698-f459faf64190', '..contains label link');
$mech->content_contains('An alias', '..contains alias name');
$mech->content_contains('An alias sort name', '..contains alias sort name');

# A sortname isn't required (MBS-6896)
($edit) = capture_edits {
    $mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/add-alias');
    $mech->submit_form(
        with_fields => {
            'edit-alias.name' => 'Another alias',
        });
} $c;

isa_ok($edit, 'MusicBrainz::Server::Edit::Label::AddAlias');
is($edit->data->{sort_name}, 'Another alias', 'sort_name defaults to name');

};

1;
