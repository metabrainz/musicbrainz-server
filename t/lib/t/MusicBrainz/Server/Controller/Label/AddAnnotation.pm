package t::MusicBrainz::Server::Controller::Label::AddAnnotation;
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

$mech->get_ok('/label/4b4ccf60-658e-11de-8a39-0800200c9a66/edit_annotation');
$mech->submit_form(
    with_fields => {
        'edit-annotation.text' => "    * Test annotation\x{0007} for a label  \r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
        'edit-annotation.changelog' => 'Changelog here',
    });

ok($mech->uri =~ qr{/label/4b4ccf60-658e-11de-8a39-0800200c9a66/?}, 'should redirect to label page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::AddAnnotation');
is_deeply($edit->data, {
    entity => {
        id => 3,
        name => 'Another Label'
    },
    text => "    * Test annotation for a label\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets",
    changelog => 'Changelog here',
    editor_id => 1
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
$mech->content_contains('Changelog here', '..has changelog entry');
$mech->content_contains('Another Label', '..has label name');
$mech->content_like(qr{label/4b4ccf60-658e-11de-8a39-0800200c9a66/?"}, '..has a link to the label');

};

1;
