package t::MusicBrainz::Server::Controller::Release::AddAnnotation;
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit_annotation');
$mech->submit_form(
    with_fields => {
        'edit-annotation.text' => "    * Test annotation\x{0007} for a release  \r\n\r\n\t\x{00A0}\r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
        'edit-annotation.changelog' => 'Changelog here',
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::AddAnnotation');
is_deeply($edit->data, {
    entity => {
        id => 2,
        name => 'Aerial'
    },
    text => "    * Test annotation for a release\n\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets",
    changelog => 'Changelog here',
    editor_id => 1
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
$mech->content_contains('Changelog here', '..has changelog entry');
$mech->content_contains('Aerial', '..has release name');
$mech->content_like(qr{release/f205627f-b70a-409d-adbe-66289b614e80/?"}, '..has a link to the artist');

};

1;
