package t::MusicBrainz::Server::Controller::Label::Delete;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/label/f34c079d-374e-4436-9448-da92dedef3ce/delete');
html_ok($mech->content);
$mech->submit_form(
    with_fields => {
        'confirm.edit_note' => q(This field's required!),
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/label/f34c079d-374e-4436-9448-da92dedef3ce}, 'should redirect to label page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Delete');
is_deeply($edit->data, {
    name => 'Empty Label',
    entity_id => 4
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
html_ok($mech->content);
$mech->content_contains('Empty Label', '..contains old label name');

};

1;
