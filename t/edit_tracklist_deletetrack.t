use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Tracklist::DeleteTrack' }

use MusicBrainz::Server::Constants qw( $EDIT_TRACKLIST_DELETETRACK );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+add_track');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::DeleteTrack');

$c->model('Edit')->load_all($edit);
ok(defined $edit->track);
is($edit->track->id, 1);
is($edit->track->edits_pending, 1);
is($edit->track->id, $edit->track_id);

$c->model('Edit')->reject($edit);

$edit = create_edit();
$c->model('Edit')->accept($edit);

my $track = $c->model('Track')->get_by_id(1);
ok(!defined $track);

my $tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);
is($tracklist->track_count, 2);
is($tracklist->tracks->[0]->position, 1);
is($tracklist->tracks->[1]->position, 2);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_TRACKLIST_DELETETRACK,
        editor_id => 1,
        track_id => 1
    );
}
