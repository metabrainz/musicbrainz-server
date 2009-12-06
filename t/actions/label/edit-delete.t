use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/delete');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'confirm.edit_note' => ' ',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/label/46f0f4cd-8aab-4b33-b698-f459faf64190}, 'should redirect to label page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Delete');
is_deeply($edit->data, {
    name => 'Warp Records',
    label_id => 2
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('Warp Records', '..contains old label name');

done_testing;
