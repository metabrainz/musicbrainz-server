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

# Editing tracks in a tracklist
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'edit tracklist tracks');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.tracklist.id' => '1',
    'edit-release.mediums.0.tracklist.tracks.0.name' => 'Renamed track',
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.name' => 'The Edit Ninja',
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.artist_id' => '2',
    'edit-release.mediums.0.tracklist.tracks.0.id' => '1',
    'edit-release.mediums.0.tracklist.tracks.0.length' => '4:20',
    'edit-release.mediums.0.tracklist.tracks.0.position' => '4',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Track::Edit', '...edit is a edit-track edit');
is_deeply($edit->data, {
    track => 1,
    new => {
        name => 'Renamed track',
        artist_credit => [
        { name => 'The Edit Ninja', artist => 2 }
        ],
        position => 4,
        length => 260000
    },
    old => {
        name => 'King of the Mountain',
        artist_credit => [
        { name => 'Artist', artist => 1 }
        ],
        position => 1,
        length => 293720
    }
}, '...edit has the right data');

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('Renamed track', '..contains new track name');
$mech->content_contains('King of the Mountain', '..contains old track name');
$mech->content_contains('The Edit Ninja', '..contains new artist name');
$mech->content_contains('Artist', '..contains new artist name');
$mech->content_contains('4', '..contains new position');
$mech->content_contains('1', '..contains old position');
$mech->content_contains('4:54', '..contains old track length');
$mech->content_contains('4:20', '..contains new track length');

done_testing;
