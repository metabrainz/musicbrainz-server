use strict;
use Test::More;
use HTTP::Request::Common;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login', 'login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

# Deleting mediums
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'deleting mediums');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.id' => '1',
    'edit-release.mediums.0.deleted' => '1',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Delete', '...edit is a delete-medium edit');
is($edit->data->{medium_id}, 1, '...edit has the correct medium id');

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
$mech->content_contains('A Sea of Honey', '..contains old medium name');
$mech->content_contains('Format', '..contains old medium format');
$mech->content_contains('1', '..contains old medium position');
$mech->content_contains('/tracklist/1', '..contains link to show the tracklist for the medium');

done_testing;
