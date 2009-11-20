#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Medium::Delete' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_medium');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Delete');

# Make sure we can load the artist
$c->model('Edit')->load_all($edit);
is($edit->medium_id, 1);
is($edit->medium->id, $edit->medium_id);
is($edit->medium->edits_pending, 1);

# Test rejecting the edit
reject_edit($c, $edit);
my $medium = $c->model('Medium')->get_by_id(1);
ok(defined $medium);
is($medium->edits_pending, 0);

# Test accepting the edit
$edit = _create_edit();
accept_edit($c, $edit);
$medium = $c->model('Medium')->get_by_id(1);
ok(!defined $medium);

done_testing;

sub _create_edit {
    my $medium = $c->model('Medium')->get_by_id(1);
    return $c->model('Edit')->create(
        edit_type => $EDIT_MEDIUM_DELETE,
        medium => $medium,
        editor_id => 1
    );
}

