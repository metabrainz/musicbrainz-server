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
    'edit-release.mediums.0.tracklist.tracks.0.name' => 'Renamed track',
    'edit-release.mediums.0.tracklist.tracks.0.id' => '1',
    'edit-release.mediums.0.tracklist.tracks.0.deleted' => '1',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::DeleteTrack', '...edit is a delete-track edit');
is_deeply($edit->data, {
    track_id => 1,
}, '...edit has the right data');

done_testing;
