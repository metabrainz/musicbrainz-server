package t::MusicBrainz::Server::Controller::Work::Edit;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/edit");
xml_ok($mech->content);
my $request = POST $mech->uri, [
    'edit-work.iswc' => 'T-123456789-0',
    'edit-work.comment' => 'A comment!',
    'edit-work.type_id' => 2,
    'edit-work.name' => 'Another name',
    'edit-work.artist_credit.names.0.name' => 'Foo',
    'edit-work.artist_credit.names.0.artist_id' => '3',
];

my $response = $mech->request($request);
ok($mech->success);
ok($mech->uri =~ qr{/work/745c079d-374e-4436-9448-da92dedef3ce$});
xml_ok($mech->content);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');
is_deeply($edit->data, {
    entity_id => 1,
    new => {
        name => 'Another name',
        type_id => 2,
        comment => 'A comment!',
        iswc => 'T-123.456.789-0',
        artist_credit => [
        { artist => 3, name => 'Foo' }
        ]
    },
    old => {
        type_id => 1,
        comment => undef,
        iswc => 'T-000.000.001-0',
        name => 'Dancing Queen',
        artist_credit => [
        { artist => 6, name => 'ABBA' }
        ]
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('Another name', '..has new name');
$mech->content_contains('Dancing Queen', '..has old name');
$mech->content_contains('T-123.456.789-0', '..has new iswc');
$mech->content_contains('T-000.000.001-0', '..has old iswc');
$mech->content_contains('Symphony', '..has new work type');
$mech->content_contains('Composition', '..has old work type');
$mech->content_contains('A comment!', '..has new comment');
$mech->content_contains('Foo', '..has new artist');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce', '...and links to artist');
$mech->content_contains('ABBA', '..has old artist');
$mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', '...and links to artist');

};

1;
