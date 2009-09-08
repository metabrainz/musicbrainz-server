#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Data::Edit' };

{
    package MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_type { 123 }
    MockEdit->register_type;
}

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Types qw( :edit_status );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
MusicBrainz::Server::Test->prepare_raw_test_database($c, '+edit');
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);

# Find all edits
my ($edits, $hits) = $edit_data->find({}, 10, 0);
is($hits, 5);
is(scalar @$edits, 5);

# Check we get the edits in descending ID order
is($edits->[$_]->id, 5 - $_) for (0..4);

# Find edits with a certain status
($edits, $hits) = $edit_data->find({ status => $STATUS_OPEN }, 10, 0);
is($hits, 3);
is(scalar @$edits, 3);
is($edits->[0]->id, 5);
is($edits->[1]->id, 3);
is($edits->[2]->id, 1);

# Find edits by a specific editor
($edits, $hits) = $edit_data->find({ editor => 1 }, 10, 0);
is($hits, 2);
is(scalar @$edits, 2);
is($edits->[0]->id, 3);
is($edits->[1]->id, 1);

# Find edits by a specific editor with a certain status
($edits, $hits) = $edit_data->find({ editor => 1, status => $STATUS_OPEN }, 10, 0);
is($hits, 2);
is(scalar @$edits, 2);
is($edits->[0]->id, 3);
is($edits->[1]->id, 1);

# Find edits with 0 results
($edits, $hits) = $edit_data->find({ editor => 122 }, 10, 0);
is($hits, 0);
is(scalar @$edits, 0);

# Find edits by a certain artist
($edits, $hits) = $edit_data->find({ artist => 1 }, 10, 0);
is($hits, 2);
is(scalar @$edits, 2);
is($edits->[0]->id, 4);
is($edits->[1]->id, 1);

($edits, $hits) = $edit_data->find({ artist => 1, status => $STATUS_APPLIED }, 10, 0);
is($hits, 1);
is(scalar @$edits, 1);
is($edits->[0]->id, 4);

# Find edits over multiple entities
($edits, $hits) = $edit_data->find({ artist => [1,2] }, 10, 0);
is($hits, 1);
is(scalar @$edits, 1);
is($edits->[0]->id, 4);

# Test accepting edits 
my $edit = $edit_data->get_by_id(1);
$edit_data->accept($edit);

my $editor = $c->model('Editor')->get_by_id($edit->editor_id);
is($editor->accepted_edits, 13);

# Test rejecting edits
$edit = $edit_data->get_by_id(3);
$edit_data->reject($edit);

$editor = $c->model('Editor')->get_by_id($edit->editor_id);
is($editor->rejected_edits, 3);

done_testing;
