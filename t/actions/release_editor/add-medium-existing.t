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

# Adding new mediums with existing tracklists
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'adding new mediums (existing tracklist)');
my $request = POST $mech->uri, [
    'edit-release.mediums.2.name' => 'Unreleased Hits',
    'edit-release.mediums.2.tracklist.id' => '3',
    'edit-release.mediums.2.format_id' => '1',
    'edit-release.mediums.2.medium' => '3',
    'edit-release.mediums.2.position' => '3',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Create', '...edit isa a create-medium edit');
is_deeply($edit->data, {
    release_id => 1,
    position => 3,
    tracklist_id => 3,
    format_id => 1,
    name => 'Unreleased Hits',
}, '...edit has the right data');

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
xml_ok($mech->content, '..is valid xml');
$mech->content_contains('Unreleased Hits', '..contains medium name');
$mech->content_contains('3', '..contains medium position'); # This is a really sloppy test...
$mech->content_contains('Aerial', '..contains release name');
$mech->content_contains('/release/f205627f-b70a-409d-adbe-66289b614e80', '...with a link to the release');
$mech->content_contains('Artist', '..contains release artist name');
$mech->content_contains('/artist/945c079d-374e-4436-9448-da92dedef3cf', '...with a link to the artist');
$mech->content_contains('/tracklist/3', '..contains a link to the tracklist');

done_testing;
