package t::MusicBrainz::Server::Controller::Artist::AddAnnotation;
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

# Test adding annotations
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation');
$mech->submit_form(
    with_fields => {
        'edit-annotation.text' => "    * Test annotation\x{0007} for an artist  \r\n\t\x{00A0}\r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
        'edit-annotation.changelog' => 'Changelog here',
    });

ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce/?$}, 'should redirect to artist page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAnnotation');
is_deeply($edit->data, {
    entity => {
        id => 3,
        name => 'Test Artist',
    },
    text => "    * Test annotation for an artist\n\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets",
    changelog => 'Changelog here',
    editor_id => 1
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');

$mech->content_contains('Changelog here', '..has changelog entry');
$mech->content_contains('Test Artist', '..has artist name');
$mech->content_like(qr{artist/745c079d-374e-4436-9448-da92dedef3ce/?"}, '..has a link to the artist');

};

1;
