#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 14;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Medium::Create'; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_CREATE );
use MusicBrainz::Server::Types qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+create_medium');

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_MEDIUM_CREATE,
    editor_id => 1,
    name => 'Studio',
    position => 1,
    format_id => 1,
    release_id => 1,
    tracklist_id => 1
);

isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Create');
is($edit->entity_model, 'Medium');
is($edit->entity_id, $edit->medium_id);

ok(defined $edit->medium_id);
ok(defined $edit->id);

my $medium = $c->model('Medium')->get_by_id($edit->medium_id);
is($medium->name, 'Studio');
is($medium->format_id, 1);
is($medium->tracklist_id, 1);
is($medium->position, 1);
is($medium->release_id, 1);
is($medium->edits_pending, 1);

$c->model('Edit')->accept($edit);

$medium = $c->model('Medium')->get_by_id($edit->medium_id);
is($medium->edits_pending, 0);

## Create a medium to reject
$edit = $c->model('Edit')->create(
    edit_type => $EDIT_MEDIUM_CREATE,
    editor_id => 1,
    name => 'Live',
    position => 2,
    format_id => 1,
    release_id => 1,
    tracklist_id => 1
);

my $medium_id = $edit->medium_id;
$c->model('Edit')->reject($edit);

$medium = $c->model('Medium')->get_by_id($medium_id);
ok(!defined $medium);
