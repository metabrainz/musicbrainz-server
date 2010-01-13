use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce/remove-puid?puid=b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
xml_ok($mech->content);
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
    recording_id => 1,
    recording_puid_id => 1,
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', '..contains puid');
$mech->content_contains('Dancing Queen', '..contains recording name');

done_testing;
