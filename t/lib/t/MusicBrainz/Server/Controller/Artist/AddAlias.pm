package t::MusicBrainz::Server::Controller::Artist::AddAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test adding aliases
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/add-alias');
$mech->submit_form(
    with_fields => {
        'edit-alias.name' => 'An alias',
        'edit-alias.sort_name' => 'Artist, Test'
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAlias');
is_deeply($edit->data, {
    locale => undef,
    entity => {
        id => 3,
        name => 'Test Artist'
    },
    name => 'An alias',
    sort_name => 'Artist, Test',
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

$mech->content_contains('Test Artist', '..contains artist name');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce', '..contains artist link');
$mech->content_contains('An alias', '..contains alias name');
$mech->content_contains('Artist, Test', '..contains alias sort name inferred from artist');

# A sortname isn't required (MBS-6896)
($edit) = capture_edits {
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/add-alias');
    $mech->submit_form(
        with_fields => {
            'edit-alias.name' => 'Another alias',
        });
} $c;

isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAlias');
is($edit->data->{sort_name}, 'Another alias', 'sort_name defaults to name');

};

1;
