#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Artist::Merge' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ artist => [1, 2] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $a1 = $c->model('Artist')->get_by_id(1);
my $a2 = $c->model('Artist')->get_by_id(2);
is($a1->edits_pending, 1);
is($a2->edits_pending, 1);

$c->model('Edit')->reject($edit);

# Test loading entities
$edit = $c->model('Edit')->get_by_id($edit->id);
TODO: {
    local $TODO = 'Support loading artists with non-conventional attribute names';
#    $c->model('Edit')->load_all($edit);
    ok(defined $edit->old_artist);
    ok(defined $edit->new_artist);
#    is($edit->old_artist->id, $edit->old_artist_id);
#    is($edit->new_artist->id, $edit->new_artist_id);
}

$a1 = $c->model('Artist')->get_by_id(1);
$a2 = $c->model('Artist')->get_by_id(2);
is($a1->edits_pending, 0);
is($a2->edits_pending, 0);

$edit = create_edit();
$c->model('Edit')->accept($edit);

$a1 = $c->model('Artist')->get_by_id(1);
$a2 = $c->model('Artist')->get_by_id(2);
ok(!defined $a1);
ok(defined $a2);

is($a2->edits_pending, 0);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_MERGE,
        editor_id => 1,
        old_artist_id => 1,
        new_artist_id => 2,
    );
}
