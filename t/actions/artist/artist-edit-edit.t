use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test editing artists
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-artist.name' => 'edit artist',
        'edit-artist.sort_name' => 'artist, controller',
        'edit-artist.type_id' => '',
        'edit-artist.country_id' => 2,
        'edit-artist.gender_id' => 2,
        'edit-artist.begin_date.year' => 1990,
        'edit-artist.begin_date.month' => 01,
        'edit-artist.begin_date.day' => 02,
        'edit-artist.end_date.year' => '',
        'edit-artist.end_date.month' => '',
        'edit-artist.end_date.day' => '',
        'edit-artist.comment' => 'artist created in controller_artist.t',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce}, 'should redirect to artist page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Edit');
is_deeply($edit->data, {
        artist => 3,
        new => {
            name => 'edit artist',
            sort_name => 'artist, controller',
            type_id => undef,
            country_id => 2,
            gender_id => 2,
            comment => 'artist created in controller_artist.t',
            begin_date => {
                year => 1990,
                month => 01,
                day => 02
            },
            end_date => undef,
        },
        old => {
            name => 'Test Artist',
            sort_name => 'Artist, Test',
            type_id => 1,
            gender_id => 1,
            country_id => 1,
            comment => 'Yet Another Test Artist',
            begin_date => {
                year => 2008,
                month => 1,
                day => 2
            },
            end_date => {
                year => 2009,
                month => 3,
                day => 4
            },
        }
    });

done_testing;
