package t::MusicBrainz::Server::Controller::ReleaseGroup::Edit;
use Test::Routine;
use Test::More;
use HTTP::Request::Common;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce/edit');
html_ok($mech->content);

my $request = POST $mech->uri, [
    'edit-release-group.comment' => 'A comment!',
    'edit-release-group.primary_type_id' => 2,
    'edit-release-group.name' => 'Another name',
    'edit-release-group.artist_credit.names.0.name' => 'Foo',
    'edit-release-group.artist_credit.names.0.artist.name' => 'Bar',
    'edit-release-group.artist_credit.names.0.artist.id' => '3',
];

my $response = $mech->request($request);
ok($mech->success);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Edit');
is_deeply($edit->data, {
    new => {
        artist_credit => {
            names => [ {
                artist => { id => 3, name => 'Bar' },
                name => 'Foo',
                join_phrase => undef,
            } ]
        },
        name => 'Another name',
        comment => 'A comment!',
        type_id => 2,
    },
    old => {
        artist_credit => {
            names => [ {
                artist => { id => 6, name => 'ABBA' },
                name => 'ABBA',
                join_phrase => '',
            } ] },
        name => 'Arrival',
        comment => '',
        type_id => 1,
    },
    entity => {
        id => 1,
        name => 'Arrival'
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content, '..valid xml');
$mech->text_contains('Arrival', '..has old release group name');
$mech->text_contains('Another name', '..has new release group name');
$mech->text_contains('A comment!', '..has new comment');
$mech->text_contains('Album', '..has old type');
$mech->text_contains('Single', '..has new type');
$mech->text_contains('Foo', '..has new artist');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce', '...and links to artist');
$mech->text_contains('ABBA', '..has old artist');
$mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', '...and links to artist');

};

1;
