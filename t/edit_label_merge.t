#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Label::Merge'; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_merge');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ label => [1, 2] }, 0, 10);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $l1 = $c->model('Label')->get_by_id(1);
my $l2 = $c->model('Label')->get_by_id(2);
is($l1->edits_pending, 1);
is($l2->edits_pending, 1);

$c->model('Edit')->reject($edit);

# Test loading entities
$edit = $c->model('Edit')->get_by_id($edit->id);
TODO: {
    local $TODO = 'Support loading labels with non-conventional attribute names';
#    $c->model('Edit')->load_all($edit);
    ok(defined $edit->old_label);
    ok(defined $edit->new_label);
#    is($edit->old_label->id, $edit->old_label_id);
#    is($edit->new_label->id, $edit->new_label_id);
}

$l1 = $c->model('Label')->get_by_id(1);
$l2 = $c->model('Label')->get_by_id(2);
is($l1->edits_pending, 0);
is($l2->edits_pending, 0);

$edit = create_edit();
$c->model('Edit')->accept($edit);

$l1 = $c->model('Label')->get_by_id(1);
$l2 = $c->model('Label')->get_by_id(2);
ok(!defined $l1);
ok(defined $l2);

is($l2->edits_pending, 0);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_MERGE,
        editor_id => 1,
        old_label_id => 1,
        new_label_id => 2,
    );
}
