use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test merging artists
my $response;
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/60e5d080-c964-11de-8a39-0800200c9a66/merge');
xml_ok($mech->content);
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
        old_artist => 4,
        new_artist => 3,
    });

done_testing;
