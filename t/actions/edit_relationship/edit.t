use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/edit/relationship/edit?type0=artist&type1=recording&id=1');
xml_ok($mech->content);
$mech->content_contains('Test Alias', 'entity0');
$mech->content_contains('King of the Mountain', 'entity1');
$mech->submit_form(
    with_fields => {
        'ar.link_type_id' => '1',
        'ar.begin_date.year' => '1994',
        'ar.end_date.year' => '1995',
        'ar.attrs.instrument.0' => '3',
        'ar.attrs.additional' => '1',
    });


my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');
is_deeply($edit->data, {
    type0 => 'artist',
    type1 => 'recording',
    relationship_id => 1,
    old => {
        begin_date => {
            year => undef,
            month => undef,
            day => undef,
        },
        end_date => {
            year => undef,
            month => undef,
            day => undef,
        },
        attributes => [4],
    },
    new => {
        begin_date => {
            year => 1994,
            month => undef,
            day => undef,
        },
        end_date => {
            year => 1995,
            month => undef,
            day => undef,
        },
        attributes => [1, 3],
    },
});

done_testing;
