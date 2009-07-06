#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;

BEGIN { use_ok 'MusicBrainz::Server::Edit::ReleaseGroup::Merge' }
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_MERGE );
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);

my $edit = $edit_data->create(
    edit_type => $EDIT_RELEASEGROUP_MERGE,
    old_release_group_id => 2,
    new_release_group_id => 1,
    editor_id => 2,
);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');
is($edit->entity_model, 'ReleaseGroup');
is_deeply($edit->entity_id, [2, 1]);
is_deeply($edit->entities, { release_group => [ 2, 1 ] });

my $rg = $rg_data->get_by_id(2);
ok(defined $rg);
is($rg->edits_pending, 1);

$rg = $rg_data->get_by_id(1);
is($rg->edits_pending, 1);

$edit_data->accept($edit);

$rg = $rg_data->get_by_id(2);
ok(!defined $rg);

$rg = $rg_data->get_by_id(1);
ok(defined $rg);
is($rg->edits_pending, 0);
