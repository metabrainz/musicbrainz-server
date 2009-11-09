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
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.artist_id' => '5',
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
        { name => 'The Edit Ninja', artist => 5 }
        ],
        position => 4,
    },
    old => {
        name => 'King of the Mountain',
        artist_credit => [
        { name => 'Artist', artist => 1 }
        ],
        position => 1
    }
}, '...edit has the right data');

TODO: {
    local $TODO = 'Support editing the length of tracks';
    ok(exists $edit->data->{new}->{length});
    ok(exists $edit->data->{old}->{length});
}

done_testing;