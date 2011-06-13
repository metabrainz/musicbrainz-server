#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'MusicBrainz::Server::EditQueue' };

use Sql;
use Log::Dispatch;
use DateTime;
use DateTime::Duration;
use MusicBrainz::Server::DatabaseConnectionFactory;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Connector;
use MusicBrainz::Server::Edit;
use MusicBrainz::Server::Constants qw( :edit_type :quality );
use MusicBrainz::Server::Types qw( :edit_status );

{
    package MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_name { 'Mock edit' }
    sub edit_type { 1234 }
}

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+inserttestdata-with-truncate');
MusicBrainz::Server::Test->prepare_test_database($c, '+editqueue-truncate');
MusicBrainz::Server::Test->prepare_raw_test_database($c, '+editqueue_raw-truncate');
MusicBrainz::Server::Test->prepare_test_database($c, '+editqueue');
MusicBrainz::Server::Test->prepare_raw_test_database($c, '+editqueue_raw');

my $sql = Sql->new($c->dbh);
my $raw_sql = Sql->new($c->raw_dbh);

my $log = Log::Dispatch->new( outputs => [ [ 'Null', min_level => 'debug' ] ] );
#my $log = Log::Dispatch->new( outputs => [ [ 'Screen', min_level => 'debug' ] ] );
my $queue;

$c->model('Edit')->create(
    edit_type => $EDIT_ARTIST_DELETE,
    editor_id => 1,
    to_delete => $c->model('Artist')->get_by_id(3)
);

$c->model('Edit')->create(
    edit_type => $EDIT_ARTIST_DELETE,
    editor_id => 1,
    to_delete => $c->model('Artist')->get_by_id(4)
);

my $edit = $c->model('Edit')->get_by_id(100);

my $artist = $c->model('Artist')->get_by_id(3);
is($artist->edits_pending, 1);

$c->model('Edit')->cancel($edit);

$edit = $c->model('Edit')->get_by_id(100);
is($edit->status, $STATUS_TOBEDELETED);

$edit = $c->model('Edit')->get_by_id(101);
is($edit->status, $STATUS_OPEN);

$artist = $c->model('Artist')->get_by_id(4);
is($artist->edits_pending, 1);

# Close a to-be-deleted edit
$queue = MusicBrainz::Server::EditQueue->new( c => $c, log => $log );
my $errors = $queue->process_edits;
is($errors, 0, 'without errors');

$edit = $c->model('Edit')->get_by_id(100);
is($edit->status, $STATUS_DELETED, 'deleted');

$edit = $c->model('Edit')->get_by_id(101);
is($edit->status, $STATUS_OPEN, 'not changed');

$raw_sql->auto_commit(1);
$raw_sql->do("UPDATE edit SET yes_votes=100 WHERE id=101");

# Acquire an exclusive lock on the edit
my $raw_db = MusicBrainz::Server::DatabaseConnectionFactory->get('RAWDATA');
my $raw2   = MusicBrainz::Server::Test::Connector->new(database => $raw_db);

my $sql2 = Sql->new($raw2->dbh);
$sql2->begin;
$sql2->select_single_row_array('SELECT * FROM edit WHERE id=101 FOR UPDATE');

# Try to apply an edit, but fail because it's being approved by somebody on the website
$queue = MusicBrainz::Server::EditQueue->new( c => $c, log => $log );
$errors = $queue->process_edits;
is($errors, 3, 'with errors');

$edit = $c->model('Edit')->get_by_id(101);
is($edit->status, $STATUS_OPEN, 'still not changed');

# Release the lock
$sql2->commit;

# Apply an edit
$queue = MusicBrainz::Server::EditQueue->new( c => $c, log => $log );
$errors = $queue->process_edits;
is($errors, 0, 'without errors');

$edit = $c->model('Edit')->get_by_id(101);
is($edit->status, $STATUS_APPLIED, 'applied');

# Low-level tests

# Expired one day ago, without votes
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(0);
$edit->no_votes(0);
$edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
my $status = $queue->_determine_new_status($edit);
is($status, $STATUS_APPLIED);

# Expired one day ago, without votes
$edit = MockEdit->new();
$edit->quality($QUALITY_HIGH);
$edit->yes_votes(0);
$edit->no_votes(0);
$edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, $STATUS_FAILEDVOTE);

# Expired one day ago, 1 no vote, 0 yes votes
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(0);
$edit->no_votes(1);
$edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, $STATUS_FAILEDVOTE);

# Expired one day ago, 0 no votes, 1 yes vote
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(1);
$edit->no_votes(0);
$edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, $STATUS_APPLIED);

# Expired one day ago, 1 no vote, 1 yes vote
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(1);
$edit->no_votes(1);
$edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, $STATUS_FAILEDVOTE);

# Not expired, without votes
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(0);
$edit->no_votes(0);
$edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, undef);

# Not expired, 3 yes votes, 0 no votes
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(3);
$edit->no_votes(0);
$edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, $STATUS_APPLIED);

# Not expired, 0 yes votes, 3 no votes
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(0);
$edit->no_votes(3);
$edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, $STATUS_FAILEDVOTE);

# Not expired, 2 yes votes, 0 no votes
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(2);
$edit->no_votes(0);
$edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, undef);

# Not expired, 0 yes votes, 2 no votes
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(0);
$edit->no_votes(2);
$edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, undef);

# Not expired, 3 yes votes, 1 no vote
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(3);
$edit->no_votes(1);
$edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, undef);

# Not expired, 1 yes vote, 3 no votes
$edit = MockEdit->new();
$edit->quality($QUALITY_NORMAL);
$edit->yes_votes(1);
$edit->no_votes(3);
$edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
$status = $queue->_determine_new_status($edit);
is($status, undef);

done_testing;
