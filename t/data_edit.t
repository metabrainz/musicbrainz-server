#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'MusicBrainz::Server::Data::Edit' };

{
    package MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_type { 123 }
}

use Sql;
use MusicBrainz;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Types qw( :edit_status );

use MusicBrainz::Server::EditRegistry;
MusicBrainz::Server::EditRegistry->register_type("MockEdit");

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
MusicBrainz::Server::Test->prepare_raw_test_database($c, '+edit');
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);

my $sql = Sql->new($c->dbh);
my $raw_sql = Sql->new($c->raw_dbh);

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
$sql->begin;
$raw_sql->begin;
$edit_data->accept($edit);
$sql->commit;
$raw_sql->commit;

my $editor = $c->model('Editor')->get_by_id($edit->editor_id);
is($editor->accepted_edits, 13);

# Test rejecting edits
$edit = $edit_data->get_by_id(3);
$sql->begin;
$raw_sql->begin;
$edit_data->reject($edit, $STATUS_FAILEDVOTE);
$sql->commit;
$raw_sql->commit;

$editor = $c->model('Editor')->get_by_id($edit->editor_id);
is($editor->rejected_edits, 3);

# Test approving edits, while something (editqueue) is holding a lock on it

# Acquire an exclusive lock on the edit
my $mb2 = MusicBrainz->new;
$mb2->Login(db => 'RAWDATA');
my $sql2 = Sql->new($mb2->dbh);
$sql2->begin;
$sql2->select_single_row_array('SELECT * FROM edit WHERE id=5 FOR UPDATE');

$edit = $edit_data->get_by_id(5);
throws_ok { $edit_data->approve($edit) } qr/could not obtain lock/;

# Release the lock
$sql2->commit;

# Test approving edits, successfully this time

$edit = $edit_data->get_by_id(5);
$edit_data->approve($edit);

$edit = $edit_data->get_by_id(5);
is($edit->status, $STATUS_APPLIED);

# Test canceling

$edit = $edit_data->get_by_id(2);
$edit_data->cancel($edit);

$edit = $edit_data->get_by_id(2);
is($edit->status, $STATUS_TOBEDELETED);

# Test deleting

$sql->begin;
$raw_sql->begin;
$edit_data->reject($edit, $STATUS_DELETED);
$sql->commit;
$raw_sql->commit;

$edit = $edit_data->get_by_id(2);
is($edit->status, $STATUS_DELETED);

done_testing;
