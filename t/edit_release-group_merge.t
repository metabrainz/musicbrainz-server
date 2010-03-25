#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::ReleaseGroup::Merge' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_merge');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');

my ($edits) = $c->model('Edit')->find({ release_group => [1, 2] }, 10, 0);
is($edits->[0]->id, $edit->id);

my $rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
is($rgs->{1}->edits_pending, 1);
is($rgs->{2}->edits_pending, 1);

reject_edit($c, $edit);
$rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
ok(defined $rgs->{1});
ok(defined $rgs->{2});

$edit = create_edit();
accept_edit($c, $edit);
$rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
ok(defined $rgs->{1});
ok(!defined $rgs->{2});

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_MERGE,
        editor_id => 1,
        old_entities => [
            { id => 2, name => 'Old RG 1' }
        ],
        new_entity_id => 1,
    );
}
