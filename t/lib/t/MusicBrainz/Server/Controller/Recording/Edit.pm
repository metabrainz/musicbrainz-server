package t::MusicBrainz::Server::Controller::Recording::Edit;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );
use HTTP::Request::Common;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok("/recording/123c079d-374e-4436-9448-da92dedef3ce/edit");
html_ok($mech->content);
my $request = POST $mech->uri, [
    'edit-recording.length' => '1:23',
    'edit-recording.comment' => 'A comment!',
    'edit-recording.name' => 'Another name',
    'edit-recording.artist_credit.names.0.name' => 'Foo',
    'edit-recording.artist_credit.names.0.artist_id' => '3',
];

my $response = $mech->request($request);
ok($mech->success);
ok($mech->uri =~ qr{/recording/123c079d-374e-4436-9448-da92dedef3ce$});
html_ok($mech->content);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Edit');
is_deeply($edit->data, {
    entity => {
        id => 1,
        name => 'Dancing Queen'
    },
    new => {
        name => 'Another name',
        comment => 'A comment!',
        length => 83000,
        artist_credit => [
        { artist => 3, name => 'Foo' }
        ]
    },
    old => {
        comment => undef,
        length => 123456,
        name => 'Dancing Queen',
        artist_credit => [
        { artist => 6, name => 'ABBA' }
        ]
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content, '..valid xml');
$mech->content_contains('Another name', '..has new name');
$mech->content_contains('Dancing Queen', '..has old name');
$mech->content_contains('1:23', '..has new length');
$mech->content_contains('2:03', '..has old length');
$mech->content_contains('A comment!', '..has new comment');
$mech->content_contains('Foo', '..has new artist');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce', '...and links to artist');
$mech->content_contains('ABBA', '..has old artist');
$mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', '...and links to artist');

};

1;
