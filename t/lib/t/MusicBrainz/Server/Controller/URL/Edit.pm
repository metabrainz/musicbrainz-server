package t::MusicBrainz::Server::Controller::URL::Edit;
use Test::Routine;
use Test::More;
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
        'edit-url.description' => 'Google'
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::URL::Edit');
is_deeply($edit->data, {
    entity => {
        id => 1,
        name => 'http://musicbrainz.org/'
    },
    new => {
        url => 'http://google.com/',
        description => 'Google',
    },
    old => {
        url => 'http://musicbrainz.org/',
        description => 'MusicBrainz',
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content, '..valid xml');
$mech->content_contains('http://google.com', '..has new URI');
$mech->content_contains('http://musicbrainz.org/', '..has old URI');
$mech->content_contains('MusicBrainz', '..has old description');
$mech->content_contains('Google', '..has new description');


};

1;
