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

# Adding new tracks
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'adding new tracks');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.tracklist.id' => '1',
    'edit-release.mediums.0.tracklist.tracks.0.name' => 'New track',
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.name' => 'The Edit Ninja',
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.artist_id' => '2',
    'edit-release.mediums.0.tracklist.tracks.0.length' => '4:20',
    'edit-release.mediums.0.tracklist.tracks.0.position' => '4',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::AddTrack', '...edit is a add-track edit');
is_deeply($edit->data, {
    tracklist_id => 1,
    name => 'New track',
    artist_credit => [
    { artist => 2, name => 'The Edit Ninja' }
    ],
    position => 4
}, '...edit has the right data');

my $track = $c->model('Track')->get_by_id($edit->track_id);

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
xml_ok($mech->content, '..xml is valid');
$mech->content_contains('New track', '..contains track name');
$mech->content_contains('A new recording was created for this track',
                        '..contains indicitation that this is a new recording');
$mech->content_contains('/tracklist/1', '..contains a link to the tracklist');
$mech->content_contains('The Edit Ninja', '..contains the artist name');
$mech->content_contains('/artist/9f5ad190-caee-11de-8a39-0800200c9a66', '...and a link to the artist');

TODO:
{
    local $TODO = 'Length in the edit';
    ok(exists $edit->data->{length});
    $mech->content_contains('4:20', '..contains the track length');
}

done_testing;
