use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Data::Vote' }

use MusicBrainz::Server::Types qw( :vote );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+vote');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

{
    package MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_type { 1 }
    MockEdit->register_type;
}

my $edit = $c->model('Edit')->create(
    editor_id => 1,
    edit_type => 1,
    foo => 'bar',
);

# Test voting on an edit
$c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_NO });
$c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_YES });
$c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_ABSTAIN });
$c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_YES });

$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Vote')->load_for_edits($edit);

is(scalar @{ $edit->votes }, 4);
is($edit->votes->[0]->vote, $VOTE_NO);
is($edit->votes->[1]->vote, $VOTE_YES);
is($edit->votes->[2]->vote, $VOTE_ABSTAIN);
is($edit->votes->[3]->vote, $VOTE_YES);

is($edit->votes->[$_]->superseded, 1) for 0..2;
is($edit->votes->[3]->superseded, 0);
is($edit->votes->[$_]->editor_id, 2) for 0..3;

# Make sure the person who created a vote cannot vote
$c->model('Vote')->enter_votes(1, { edit_id => $edit->id, vote => $VOTE_NO });
$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Vote')->load_for_edits($edit);

is(scalar @{ $edit->votes }, 4);
is($edit->votes->[$_]->editor_id, 2) for 0..3;

# Check the vote counts
$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Vote')->load_for_edits($edit);
is($edit->yes_votes, 1);
is($edit->no_votes, 0);

$c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_ABSTAIN });
$edit = $c->model('Edit')->get_by_id($edit->id);
is($edit->yes_votes, 0);
is($edit->no_votes, 0);

done_testing;
