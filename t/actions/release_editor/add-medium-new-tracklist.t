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

# New medium, new tracklist
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'adding new mediums (existing tracklist)');
my $request = POST $mech->uri, [
    'edit-release.mediums.2.name' => 'Unreleased Hits',
    'edit-release.mediums.2.format_id' => '1',
    'edit-release.mediums.2.position' => '4',
    'edit-release.mediums.2.tracklist.tracks.0.name' => 'New track',
    'edit-release.mediums.2.tracklist.tracks.0.artist_credit.names.0.name' => 'The Edit Ninja',
    'edit-release.mediums.2.tracklist.tracks.0.artist_credit.names.0.artist_id' => '2',
    'edit-release.mediums.2.tracklist.tracks.0.length' => '1:59',
    'edit-release.mediums.2.tracklist.tracks.0.position' => '1',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Create', '...edit isa a create-medium edit');
is($edit->data->{release_id}, 1, '...edit has the right data');
is($edit->data->{position}, 4, '...edit has the right data');
is($edit->data->{format_id}, 1, '...edit has the right data');
is($edit->data->{name}, 'Unreleased Hits', '...edit has the right data');
ok($edit->data->{tracklist_id}, '...edit has the right data');

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
xml_ok($mech->content, '..is valid xml');
$mech->content_contains('Unreleased Hits', '..contains medium name');
$mech->content_contains('5', '..contains medium position'); # This is a really sloppy test...
$mech->content_contains('Format', '..contains format name');
$mech->content_contains('Aerial', '..contains release name');
$mech->content_contains('/release/f205627f-b70a-409d-adbe-66289b614e80', '...with a link to the release');
$mech->content_contains('Artist', '..contains release artist name');
$mech->content_contains('/artist/945c079d-374e-4436-9448-da92dedef3cf', '...with a link to the artist');

done_testing;
