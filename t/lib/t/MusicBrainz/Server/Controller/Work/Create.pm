package t::MusicBrainz::Server::Controller::Work::Create;
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

$mech->get_ok('/work/create');
xml_ok($mech->content);

my $request = POST $mech->uri, [
    'edit-work.comment' => 'A comment!',
    'edit-work.type_id' => 1,
    'edit-work.name' => 'Enchanted',
    'edit-work.artist_credit.names.0.name' => 'Variant',
    'edit-work.artist_credit.names.0.artist_id' => '3',
    'edit-work.iswc' => 'T-000.000.001-0',
];

my $response = $mech->request($request);
ok($mech->success);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Create');
is_deeply($edit->data, {
    artist_credit => [ { artist => 3, name => 'Variant' } ],
    name          => 'Enchanted',
    comment       => 'A comment!',
    type_id       => 1,
    iswc          => 'T-000.000.001-0',
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('Enchanted', '..has work name');
$mech->content_contains('A comment!', '..has comment');
$mech->content_contains('Composition', '..has type');
$mech->content_contains('Variant', '..hasartist');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce', '...and links to artist');

};

1;
