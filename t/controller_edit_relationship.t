#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_raw_test_database($c);
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/edit/relationship/delete?type0=artist&type1=recording&id=1');
$mech->content_contains('Test Alias', 'entity0');
$mech->content_contains('King of the Mountain', 'entity1');
my $response = $mech->submit_form(
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
