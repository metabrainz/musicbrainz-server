use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release-group/ecc33260-454c-11de-8a39-0800200c9a66/delete');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'confirm.edit_note' => ' ',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/release-group/ecc33260-454c-11de-8a39-0800200c9a66}, 'should redirect to artist page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Delete');
is_deeply($edit->data, { release_group => 3, name => 'Test RG 1' });

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
xml_ok($mech->content, '..is valid xml');
$mech->content_contains('Test RG 1', '..contains release group name');

done_testing;
