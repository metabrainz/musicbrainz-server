use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my ($res, $c) = ctx_request('/');

# Test creating new artists via the create artist form
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/create');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-artist.name' => 'controller artist',
        'edit-artist.sort_name' => 'artist, controller',
        'edit-artist.type_id' => 1,
        'edit-artist.country_id' => 2,
        'edit-artist.gender_id' => 2,
        'edit-artist.begin_date.year' => 1990,
        'edit-artist.begin_date.month' => 01,
        'edit-artist.begin_date.day' => 02,
        'edit-artist.end_date.year' => 2003,
        'edit-artist.end_date.month' => 4,
        'edit-artist.end_date.day' => 15,
        'edit-artist.comment' => 'artist created in controller_artist.t',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/artist/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})}, 'should redirect to artist page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');
is_deeply($edit->data, {
        name => 'controller artist',
        sort_name => 'artist, controller',
        type_id => 1,
        country_id => 2,
        gender_id => 2,
        comment => 'artist created in controller_artist.t',
        begin_date => {
            year => 1990,
            month => 01,
            day => 02
        },
        end_date => {
            year => 2003,
            month => 4,
            day => 15
        },
    });

done_testing;
