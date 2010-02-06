use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/merge');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'filter.query' => 'Another',
    }
);
$response = $mech->submit_form(
    with_fields => {
        'dest' => '4b4ccf60-658e-11de-8a39-0800200c9a66'
    });
$response = $mech->submit_form(
    with_fields => { 'confirm.edit_note' => ' ' }
);
ok($mech->uri =~ qr{/label/4b4ccf60-658e-11de-8a39-0800200c9a66});

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Merge');
is_deeply($edit->data, {
        old_entity_id => 2,
        new_entity_id => 3,
    });

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('Warp Records', '..contains old name');
$mech->content_contains('/label/46f0f4cd-8aab-4b33-b698-f459faf64190', '..contains old label link');
$mech->content_contains('Another Label', '..contains new name');
$mech->content_contains('/label/4b4ccf60-658e-11de-8a39-0800200c9a66', '..contains new label link');

done_testing;
