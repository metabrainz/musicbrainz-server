#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Tracklist::AddTrack' }

use MusicBrainz::Server::Constants qw( $EDIT_TRACKLIST_ADDTRACK );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+add_track');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

# ----
# Try appending a track
my $edit = append_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::AddTrack');

# Make sure the tracklist looks correct
my $tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);

is($tracklist->tracks->[3]->edits_pending, 1);
is($tracklist->tracks->[3]->recording_id, 1);

verify_tracklist($tracklist, [1, 'First Track'], [2, 'Second Track'], [3, 'Third Track'],
    [4, 'Appended Track']);


# Test rejecting the edit
reject_edit($c, $edit);

# Make sure the track has been removed
$tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);

verify_tracklist($tracklist, [1, 'First Track'], [2, 'Second Track'], [3, 'Third Track']);


# Test accepting the edit
$edit = append_edit();
accept_edit($c, $edit);

# Make sure the tracklist looks correct
$tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);

is($tracklist->tracks->[3]->edits_pending, 0);
is($tracklist->tracks->[3]->recording_id, 1);
verify_tracklist($tracklist, [1, 'First Track'], [2, 'Second Track'], [3, 'Third Track'],
    [4, 'Appended Track']);


# ---- 
# Try prepending a track
$edit = prepend_edit();

# Make sure the tracklist looks correct
$tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);

is($tracklist->tracks->[0]->edits_pending, 1);
is($tracklist->tracks->[0]->recording_id, 1);
verify_tracklist($tracklist, [1, 'Prepended Track'], [2, 'First Track'], [3, 'Second Track'],
    [4, 'Third Track'], [5, 'Appended Track']);

# Test rejecting the edit
reject_edit($c, $edit);

# Make sure the track has been removed
$tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);

verify_tracklist($tracklist, [1, 'First Track'], [2, 'Second Track'], [3, 'Third Track'],
    [4, 'Appended Track']);

# Test accepting the edit
$edit = prepend_edit();
accept_edit($c, $edit);

# Make sure the tracklist looks correct
$tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);

is($tracklist->tracks->[0]->edits_pending, 0);
is($tracklist->tracks->[0]->recording_id, 1);
verify_tracklist($tracklist, [1, 'Prepended Track'], [2, 'First Track'], [3, 'Second Track'],
    [4, 'Third Track'], [5, 'Appended Track']);


# ----
# Make sure a recording is created if recording_id is undef
$edit = $c->model('Edit')->create(
    edit_type => $EDIT_TRACKLIST_ADDTRACK,
    editor_id => 1,
    tracklist_id => 1,
    position => 1,
    name => 'Auto-created Recording',
    artist_credit => [ { artist => 1, name => 'Foo' } ]
);

$tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);

ok(defined $tracklist->tracks->[0]->recording_id);
ok($tracklist->tracks->[0]->recording_id > 3);

done_testing;

sub append_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_TRACKLIST_ADDTRACK,
        editor_id => 1,
        tracklist_id => 1,
        position => 4,
        name => 'Appended Track',
        recording_id => 1,
        artist_credit => [ { artist => 1, name => 'Some artist' } ],
    );
}

sub prepend_edit {
    $c->model('Edit')->create(
        edit_type => $EDIT_TRACKLIST_ADDTRACK,
        editor_id => 1,
        tracklist_id => 1,
        position => 1,
        name => 'Prepended Track',
        recording_id => 1,
        artist_credit => [ { artist => 1, name => 'Some artist' } ],
    );
}

sub verify_tracklist {
    my ($tracklist, @tuples) = @_;
    my $i = 0;
    is($tracklist->track_count, @tuples);
    while(@tuples) {
        my $tup = shift @tuples;
        is($tracklist->tracks->[$i]->position, $tup->[0]);
        is($tracklist->tracks->[$i]->name, $tup->[1]);

        $i++;
    };
}
