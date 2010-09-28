#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Work::Merge' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_WORK_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+work');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ work => [1, 2] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $a1 = $c->model('Work')->get_by_id(1);
my $a2 = $c->model('Work')->get_by_id(2);
is($a1->edits_pending, 1);
is($a2->edits_pending, 1);

reject_edit($c, $edit);

$a1 = $c->model('Work')->get_by_id(1);
$a2 = $c->model('Work')->get_by_id(2);
is($a1->edits_pending, 0);
is($a2->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);

$a1 = $c->model('Work')->get_by_id(1);
$a2 = $c->model('Work')->get_by_id(2);
ok(!defined $a1);
ok(defined $a2);

is($a2->edits_pending, 0);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_WORK_MERGE,
        editor_id => 1,
        old_entities => [ { id => 1, name => 'Old Work' } ],
        new_entity => { id => 2, name => 'New Work' },
    );
}
