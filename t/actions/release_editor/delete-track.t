use strict;
use Test::More;
use HTTP::Request::Common;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request '/';
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login', 'login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

# Deleting tracks
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'deleting tracks');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.tracklist.id' => '1',
    'edit-release.mediums.0.tracklist.tracks.0.id' => '1',
    'edit-release.mediums.0.tracklist.tracks.0.deleted' => '1',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::DeleteTrack', '...edit is a delete-track edit');
is($edit->data->{track_id}, 1, '...edit has the right data');

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('King of the Mountain', '..contains track name');
$mech->content_contains('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8', '..contains a link to the recording');
$mech->content_contains('Artist', '..contains the artist name');
$mech->content_contains('/artist/945c079d-374e-4436-9448-da92dedef3cf', '...with a link to the artist');

done_testing;
