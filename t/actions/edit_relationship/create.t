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

$mech->get_ok('/edit/relationship/create?type0=artist&type1=recording&entity0=745c079d-374e-4436-9448-da92dedef3ce&entity1=123c079d-374e-4436-9448-da92dedef3ce');
xml_ok($mech->content);
$mech->content_contains('Test Artist', 'entity0');
$mech->content_contains('Dancing Queen', 'entity1');
$mech->submit_form(
    with_fields => {
        'ar.link_type_id' => '1',
        'ar.begin_date.year' => '1994',
        'ar.end_date.year' => '1995',
        'ar.attrs.instrument.0' => '3',
        'ar.attrs.additional' => '1',
    });


my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');
is_deeply($edit->data, {
    type0 => 'artist',
    type1 => 'recording',
    entity0 => 3,
    entity1 => 1,
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
    link_type_id => 1
});

done_testing;
