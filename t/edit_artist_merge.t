#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Artist::Merge' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

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

reject_edit($c, $edit);

$a1 = $c->model('Artist')->get_by_id(1);
$a2 = $c->model('Artist')->get_by_id(2);
is($a1->edits_pending, 0);
is($a2->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);

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
        old_entity_id => 1,
        new_entity_id => 2,
    );
}
