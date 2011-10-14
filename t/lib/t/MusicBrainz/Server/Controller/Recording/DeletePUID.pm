package t::MusicBrainz::Server::Controller::Recording::DeletePUID;
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

$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce/remove-puid?puid=b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
html_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'confirm.edit_note' => ' ',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/recording/123c079d-374e-4436-9448-da92dedef3ce}, 'should redirect to recording page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::PUID::Delete');
is_deeply($edit->data, {
    puid_id => 1,
    puid => 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0',
    client_version => 'mb_client/1.0',
    recording => {
        id => 1,
        name => 'Dancing Queen'
    },
    recording_puid_id => 1,
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content, '..valid xml');
$mech->content_contains('b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', '..contains puid');
$mech->content_contains('Dancing Queen', '..contains recording name');

};

1;
