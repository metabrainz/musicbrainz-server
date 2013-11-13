package t::MusicBrainz::Server::Controller::ReleaseGroup::Delete;
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

$mech->get_ok('/release-group/ecc33260-454c-11de-8a39-0800200c9a66/delete');
html_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'confirm.edit_note' => 'Required.',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/release-group/ecc33260-454c-11de-8a39-0800200c9a66}, 'should redirect to artist page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Delete');
is_deeply($edit->data, { entity_id => 3, name => 'Test RG 1' });

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content, '..is valid xml');
$mech->content_contains('Test RG 1', '..contains release group name');

};

1;
