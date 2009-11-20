use strict;
use Test::More;
use HTTP::Request::Common;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request '/';
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login', 'login');
xml_ok($mech->content, '...valid xml');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'edit sidebar attributes');
xml_ok($mech->content, '...valid');

# Test editing side bar attributes
my $request = POST $mech->uri, [
    'edit-release.date.year' => '2009',
    'edit-release.date.month' => '10',
    'edit-release.date.day' => '25',
    'edit-release.packaging_id' => '2',
    'edit-release.status_id', '2',
    'edit-release.language_id' => '1',
    'edit-release.script_id' => '1',
    'edit-release.country_id' => '1',
    'edit-release.barcode' => '9780596001087',
];

my $response = $mech->request($request);
ok($mech->success, '...post an edit request');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Edit', '...edit isa edit-release edit');
is_deeply($edit->data, {
    release => 1,
    new => {
        date => {
             year => 2009,
             month => 10,
             day => 25
        },
        packaging_id => 2,
        status_id => 2,
        language_id => 1,
        script_id => 1,
        country_id => 1,
        barcode => '9780596001087',
    },
    old => {
        date => {
             year => 2007,
             month => undef,
             day => undef
        },
        packaging_id => undef,
        status_id => undef,
        language_id => undef,
        script_id => undef,
        country_id => undef,
        barcode => undef,
    }
}, '...edit has the correct data');

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('2009', '..contains new year');
$mech->content_contains('10', '..contains new month');
$mech->content_contains('25', '..contains new day');
$mech->content_contains('2007', '..contains old year');
$mech->content_contains('Digipak', '..contains new packaging name');
$mech->content_contains('Promotion', '..contains new status name');
$mech->content_contains('9780596001087', '..contains new barcode');
$mech->content_contains('Ugar', '..contains new script');
$mech->content_contains('German', '..contains new language');
$mech->content_contains('United Kingdom', '..contains new country');

done_testing;
