#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Recording::Merge'; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ recording => [1, 2] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $r1 = $c->model('Recording')->get_by_id(1);
my $r2 = $c->model('Recording')->get_by_id(2);
is($r1->edits_pending, 1);
is($r2->edits_pending, 1);

reject_edit($c, $edit);

$r1 = $c->model('Recording')->get_by_id(1);
$r2 = $c->model('Recording')->get_by_id(2);
is($r1->edits_pending, 0);
is($r2->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);

$r1 = $c->model('Recording')->get_by_id(1);
$r2 = $c->model('Recording')->get_by_id(2);
ok(!defined $r1);
ok(defined $r2);

is($r2->edits_pending, 0);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_MERGE,
        editor_id => 1,
        old_entities => [ { id => 1, name => 'Old Recording' } ],
        new_entity_id => 2,
    );
}
