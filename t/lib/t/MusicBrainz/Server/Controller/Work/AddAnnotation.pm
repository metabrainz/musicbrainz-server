package t::MusicBrainz::Server::Controller::Work::AddAnnotation;
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

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation");
$mech->submit_form(
    with_fields => {
        'edit-annotation.text' => "    * Test annotation\x{0007} for a work  \r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
        'edit-annotation.changelog' => 'Changelog here',
    }
);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::AddAnnotation');
is_deeply(
    $edit->data,
    {
        entity => {
            id => 1,
            name => 'Dancing Queen'
        },
        text => "    * Test annotation for a work\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets",
        changelog => 'Changelog here',
        editor_id => 1
    }
);

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
$mech->content_contains('Changelog here', '..has changelog entry');
$mech->content_contains('Dancing Queen', '..has work name');
$mech->content_like(qr{work/745c079d-374e-4436-9448-da92dedef3ce/?"}, '..has a link to the work');
};

1;
