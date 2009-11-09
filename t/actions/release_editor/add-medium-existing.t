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

# Adding new mediums with existing tracklists
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'adding new mediums (existing tracklist)');
my $request = POST $mech->uri, [
    'edit-release.mediums.2.name' => 'Unreleased Hits',
    'edit-release.mediums.2.tracklist.id' => '3',
    'edit-release.mediums.2.format_id' => '1',
    'edit-release.mediums.2.medium' => '3',
    'edit-release.mediums.2.position' => '3',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Create', '...edit isa a create-medium edit');
is_deeply($edit->data, {
    release_id => 1,
    position => 3,
    tracklist_id => 3,
    format_id => 1,
    name => 'Unreleased Hits',
}, '...edit has the right data');

done_testing;
