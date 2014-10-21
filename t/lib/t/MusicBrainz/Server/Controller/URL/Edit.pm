package t::MusicBrainz::Server::Controller::URL::Edit;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply re );
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+url');
MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

# Test editing urls
$mech->get_ok('/url/9201840b-d810-4e0f-bb75-c791205f5b24/edit');
my $response = $mech->submit_form(
    with_fields => {
        'edit-url.url' => 'http://google.com',
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::URL::Edit');
cmp_deeply($edit->data, {
    entity => {
        id => 1,
        gid => re("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"),
        name => 'http://musicbrainz.org/'
    },
    new => {
        url => 'http://google.com/',
    },
    old => {
        url => 'http://musicbrainz.org/',
    },
    affects => 0, # not realistic, but true for the test data (unused URL entity)
    is_merge => 0,
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content, '..valid xml');
$mech->content_contains('http://google.com', '..has new URI');
$mech->content_contains('http://musicbrainz.org/', '..has old URI');

};

1;
