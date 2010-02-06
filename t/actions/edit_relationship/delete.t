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

$mech->get_ok('/edit/relationship/delete?type0=artist&type1=recording&id=1');
xml_ok($mech->content);
$mech->content_contains('Test Alias', 'entity0');
$mech->content_contains('King of the Mountain', 'entity1');
$mech->submit_form(
    with_fields => {
        'confirm.edit_note' => '',
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Delete');
is_deeply($edit->data, {
    type0 => 'artist',
    type1 => 'recording',
    relationship_id => 1
});

done_testing;
