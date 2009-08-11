#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::ReleaseGroup::Merge' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_MERGE );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_merge');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');

my ($edits) = $c->model('Edit')->find({ release_group => [1, 2] }, 0, 10);
is($edits->[0]->id, $edit->id);

my $rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
is($rgs->{1}->edits_pending, 1);
is($rgs->{2}->edits_pending, 1);

$c->model('Edit')->reject($edit);
$rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
ok(defined $rgs->{1});
ok(defined $rgs->{2});

$edit = create_edit();
$c->model('Edit')->accept($edit);
$rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
ok(defined $rgs->{1});
ok(!defined $rgs->{2});

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_MERGE,
        editor_id => 1,
        old_release_group_id => 2,
        new_release_group_id => 1,
    );
}
