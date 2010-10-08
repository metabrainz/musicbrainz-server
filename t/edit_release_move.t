#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Release::Move' };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MOVE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

# Starting point for releases
my $release_group = $c->model('ReleaseGroup')->get_by_id(2);

my $release = $c->model('Release')->get_by_id(1);
is_unchanged($release);
is($release->edits_pending, 0);

# Test editing all possible fields
my $edit = create_edit($release);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Move');

my ($edits) = $c->model('Edit')->find({ release => $release->id }, 10, 0);
is($edits->[0]->id, $edit->id);

$release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 1);
is_unchanged($release);

reject_edit($c, $edit);
$release = $c->model('Release')->get_by_id(1);
is_unchanged($release);
is($release->edits_pending, 0);

# Accept the edit
$edit = create_edit($release);
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
is($release->release_group_id, 2);
is($release->edits_pending, 0);

done_testing;

sub is_unchanged {
    my ($release) = @_;
    is($release->release_group_id, 1);
}

sub create_edit {
    my $release = shift;
    $c->model('ReleaseGroup')->load($release);
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MOVE,
        editor_id => 1,
        release => $release,
        new_release_group => $release_group
    );
}
