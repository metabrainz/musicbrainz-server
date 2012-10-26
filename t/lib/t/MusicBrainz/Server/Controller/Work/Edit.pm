package t::MusicBrainz::Server::Controller::Work::Edit;
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

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/edit");
html_ok($mech->content);
my $request = POST $mech->uri, [
    'edit-work.comment' => 'A comment!',
    'edit-work.type_id' => 2,
    'edit-work.name' => 'Another name'
];

my $response = $mech->request($request);
ok($mech->success);
ok($mech->uri =~ qr{/work/745c079d-374e-4436-9448-da92dedef3ce$});
html_ok($mech->content);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');
is_deeply($edit->data, {
    entity => {
        id => 1,
        name => 'Dancing Queen'
    },
    new => {
        name => 'Another name',
        type_id => 2,
        comment => 'A comment!',
    },
    old => {
        type_id => 1,
        comment => '',
        name => 'Dancing Queen'
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content, '..valid xml');
$mech->text_contains('Another name', '..has new name');
$mech->text_contains('Dancing Queen', '..has old name');
$mech->text_contains('Symphony', '..has new work type');
$mech->text_contains('Composition', '..has old work type');
$mech->text_contains('A comment!', '..has new comment');

};

1;
