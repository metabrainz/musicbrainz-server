#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::ReleaseGroup::Delete'; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $rg = $c->model('ReleaseGroup')->get_by_id(1);
my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Delete');

my ($edits) = $c->model('Edit')->find({ release_group => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$edit = $c->model('Edit')->get_by_id($edit->id);

$rg = $c->model('ReleaseGroup')->get_by_id(1);
is($rg->edits_pending, 1);

reject_edit($c, $edit);
$rg = $c->model('ReleaseGroup')->get_by_id(1);
ok(defined $rg);
is($rg->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);
$rg = $c->model('ReleaseGroup')->get_by_id(1);
ok(!defined $rg);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_DELETE,
        editor_id => 1,
        release_group => $rg,
    );
}
