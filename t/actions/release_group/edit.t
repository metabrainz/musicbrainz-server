use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use HTTP::Request::Common;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce/edit');
xml_ok($mech->content);

my $request = POST $mech->uri, [
    'edit-release-group.comment' => 'A comment!',
    'edit-release-group.type_id' => 2,
    'edit-release-group.name' => 'Another name',
    'edit-release-group.artist_credit.names.0.name' => 'Foo',
    'edit-release-group.artist_credit.names.0.artist_id' => '3',
];

my $response = $mech->request($request);
ok($mech->success);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Edit');
is_deeply($edit->data, {
    new => {
        artist_credit => [ { artist => 3, name => 'Foo' } ],
        name => 'Another name',
        comment => 'A comment!',
        type_id => 2,
    },
    old => {
        type_id => 1,
        name => 'Arrival',
        comment => undef,
        artist_credit => [ { artist => 6, name => 'ABBA' } ]
    },
    release_group => 1
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('Arrival', '..has old release group name');
$mech->content_contains('Another name', '..has new release group name');
$mech->content_contains('A comment!', '..has new comment');
$mech->content_contains('Album', '..has old type');
$mech->content_contains('Single', '..has new type');
$mech->content_contains('Foo', '..has new artist');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce', '...and links to artist');
$mech->content_contains('ABBA', '..has old artist');
$mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', '...and links to artist');

done_testing;
