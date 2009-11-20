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

# Editing mediums
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'edit existing mediums');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.id' => '1',
    'edit-release.mediums.0.name' => 'Renamed Medium',
    'edit-release.mediums.0.format_id' => '2',
    'edit-release.mediums.0.position' => '2',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Edit', '...edit is a edit-medium edit');
is_deeply($edit->data, {
    medium => 1,
    new => {
        name => 'Renamed Medium',
        format_id => 2,
        position => 2,
    },
    old => {
        name => 'A Sea of Honey',
        format_id => 1,
        position => 1
    }
}, '...edit has the right data');

$c->model('Edit')->load_all($edit);
use Data::Dumper;
warn Dumper $edit->display_data;


$mech->get_ok('/edit/' . $edit->id);
xml_ok($mech->content, '..valid xml');
$mech->content_contains('Renamed Medium', '..has new medium name');
$mech->content_contains('A Sea of Honey', '..has old medium name');
$mech->content_contains('Format', '..has old format name');
$mech->content_contains('Musical Box', '..has new format name');
$mech->content_contains('2', '..has new position');
$mech->content_contains('1', '..has old position');

done_testing;
