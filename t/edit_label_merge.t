#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Label::Merge'; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_merge');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ label => [1, 2] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $l1 = $c->model('Label')->get_by_id(1);
my $l2 = $c->model('Label')->get_by_id(2);
is($l1->edits_pending, 1);
is($l2->edits_pending, 1);

reject_edit($c, $edit);

$l1 = $c->model('Label')->get_by_id(1);
$l2 = $c->model('Label')->get_by_id(2);
is($l1->edits_pending, 0);
is($l2->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);

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
        old_entities => [ { id => 1, name => 'Old Artist' } ],
        new_entity_id => 2,
    );
}
