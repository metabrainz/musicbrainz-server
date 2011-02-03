package t::MusicBrainz::Server::Controller::Artist::Merge;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test merging artists
my $response;
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/60e5d080-c964-11de-8a39-0800200c9a66/merge');
html_ok($mech->content);
$response = $mech->submit_form(
    with_fields => {
        'filter.query' => 'Test',
    }
);
$response = $mech->submit_form(
    with_fields => {
        'dest' => '745c079d-374e-4436-9448-da92dedef3ce'
    });
$response = $mech->submit_form(
    with_fields => { 'confirm.edit_note' => ' ' }
);
ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce});

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');

is_deeply($edit->data, {
        old_entities => [ { name => 'Empty Artist', id => 4, } ],
        new_entity => { name => 'Test Artist', id => 3, },
    });

};

1;
