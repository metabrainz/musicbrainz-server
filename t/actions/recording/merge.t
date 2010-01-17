use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce/merge');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'filter.query' => 'King of the',
    }
);
$response = $mech->submit_form(
    with_fields => {
        'dest' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
    });
$response = $mech->submit_form(
    with_fields => { 'confirm.edit_note' => ' ' }
);
ok($mech->uri =~ qr{/recording/54b9d183-7dab-42ba-94a3-7388a66604b8});

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Merge');
is_deeply($edit->data, {
        old_entity_id => 1,
        new_entity_id => 2,
    });

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('King of the Mountain', '..contains old name');
$mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce');
$mech->content_contains('Dancing Queen', '..contains new name');
$mech->content_contains('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8', '..contains new label link');

done_testing;
