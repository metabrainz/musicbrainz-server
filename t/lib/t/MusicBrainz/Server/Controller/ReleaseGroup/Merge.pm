package t::MusicBrainz::Server::Controller::ReleaseGroup::Merge;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce/merge');
html_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'filter.query' => 'Test RG 1',
    }
);
$response = $mech->submit_form(
    with_fields => {
        'dest' => 'ecc33260-454c-11de-8a39-0800200c9a66'
    });
$response = $mech->submit_form(
    with_fields => { 'confirm.edit_note' => ' ' }
);
ok($mech->uri =~ qr{/release-group/ecc33260-454c-11de-8a39-0800200c9a66});

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');
is_deeply($edit->data, {
    old_entities => [ { name => 'Arrival', id => '1' } ],
    new_entity => { name => 'Test RG 1', id => '3' },
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content, '..valid xml');
$mech->content_contains('Arrival', '..has old release group name');
$mech->content_contains('234c079d-374e-4436-9448-da92dedef3ce', '..has link to old release group');
$mech->content_contains('Test RG 1', '..has new release group name');
$mech->content_contains('ecc33260-454c-11de-8a39-0800200c9a66', '..has a link to new release group');

};

1;
