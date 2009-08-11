#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Artist::Delete' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_delete');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Delete');

my ($edits, $hits) = $c->model('Edit')->find({ artist => 1 }, 0, 10);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $artist = $c->model('Artist')->get_by_id(1);
is($artist->edits_pending, 1);

# Make sure we can load the artist
$c->model('Edit')->load_all($edit);
is($edit->artist->id, 1);

# Test rejecting the edit
$c->model('Edit')->reject($edit);
$artist = $c->model('Artist')->get_by_id(1);
ok(defined $artist);
is($artist->edits_pending, 0);

# Test accepting the edit
$edit = _create_edit();
$c->model('Edit')->accept($edit);
$artist = $c->model('Artist')->get_by_id(1);
ok(!defined $artist);

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_DELETE,
        artist_id => 1,
        editor_id => 1
    );
}

