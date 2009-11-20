use strict;
use Test::More;
use HTTP::Request::Common;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request '/';
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test editing stuff in the "header"
$mech->get_ok('/login', 'login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'edit header details');
my $request = POST $mech->uri, [
    'edit-release.artist_credit.names.0.name' => 'Bob Marley',
    'edit-release.artist_credit.names.0.artist_id' => 2,
    'edit-release.name' => 'A new name',
    'edit-release.comment' => 'With a fancy comment',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Edit', '...edit is a edit-release edit');
is_deeply($edit->data, {
    release => 1,
    new => {
        artist_credit => [
        { name => 'Bob Marley', artist => 2 }
        ],
        name => 'A new name',
        comment => 'With a fancy comment',
    },
    old => {
        comment => undef,
        name => 'Aerial',
        artist_credit => [
        { name => 'Artist', artist => 1 }
        ]
    }
}, '...edit has the right data');

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('A new name', '..contains new name');
$mech->content_contains('Aerial', '..contains old name');
$mech->content_contains('Artist', '..contains old artist name');
$mech->content_contains('Bob Marley', '..contains new artist name');
$mech->content_contains('With a fancy comment', '..contains new comment');

done_testing;
