package t::MusicBrainz::Server::EditQueue;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use DateTime;
use Log::Dispatch;
use MusicBrainz::Server::Constants qw( :edit_type :edit_status );
use MusicBrainz::Server::EditQueue;
use Try::Tiny;

with 't::Context';

my $mock_class = 1000 + int(rand(1000));

{
    package t::MusicBrainz::Server::EditQueue::MockEditSimple;
    use Moose;
    use namespace::autoclean;

    extends 'MusicBrainz::Server::Edit';
    with 'MusicBrainz::Server::Edit::Role::NeverAutoEdit';
    sub edit_name { 'Mock edit with database votes' }
    sub edit_type { $mock_class }
}

MusicBrainz::Server::EditRegistry->register_type('t::MusicBrainz::Server::EditQueue::MockEditSimple');

{
    package t::MusicBrainz::Server::EditQueue::MockEdit;
    use Moose;
    extends 't::MusicBrainz::Server::EditQueue::MockEditSimple';
    sub edit_name { 'Mock edit with simulated votes' }
    sub edit_type { $mock_class + 1 }
    has yes_votes => ( is => 'rw', isa => 'Int' );
    has no_votes => ( is => 'rw', isa => 'Int' );
}

MusicBrainz::Server::EditRegistry->register_type('t::MusicBrainz::Server::EditQueue::MockEdit');

has null_logger => (
    is => 'ro',
    default => sub { Log::Dispatch->new( outputs => [ [ 'Null', min_level => 'debug' ] ] ); }
);

has 'edit_queue' => (
    is => 'ro',
    clearer => 'clear_edit_queue',
    lazy => 1,
    default => sub {
        my $test = shift;
        MusicBrainz::Server::EditQueue->new( c => $test->c, log => $test->null_logger );
    }
);

test 'Edit queue does not close open edits with insufficient votes' => sub {
    my $test = shift;

    $test->c->sql->do(<<~"SQL");
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (10, 'Editor', '{CLEARTEXT}pass', 'b5ba49bbd92eb35ddb35b5acd039440d', '', now());
        INSERT INTO edit (id, editor, type, status, open_time, expire_time) VALUES (101, 10, $mock_class, 1, now() - interval '6 days', now() + interval '1 day');
        INSERT INTO edit_data (edit, data) VALUES (101, '{}');
        SQL

    my $errors = $test->edit_queue->process_edits;
    is($errors, 0, 'without errors');

    my $edit = $test->c->model('Edit')->get_by_id(101);
    is($edit->status, $STATUS_OPEN, 'not changed');
};

test 'Edit queue correctly handles locked edits' => sub {
    my $test = shift;

    my $edit_queue_dbh = MusicBrainz::Server::DatabaseConnectionFactory->get_connection('TEST', fresh => 1);
    my $other_dbh = MusicBrainz::Server::DatabaseConnectionFactory->get_connection('TEST', fresh => 1);

    Sql::run_in_transaction(sub {
        $other_dbh->sql->do(<<~"SQL");
            INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (10, 'Editor', '{CLEARTEXT}pass', 'b5ba49bbd92eb35ddb35b5acd039440d', '', now());
            INSERT INTO edit (id, editor, type, status, open_time, expire_time) VALUES (101, 10, $mock_class, 1, now() - interval '7 days', now());
            INSERT INTO edit_data (edit, data) VALUES (101, '{}');

            INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
                SELECT generate_series(11, 15), 'Voter ' || generate_series(1, 5), '{CLEARTEXT}pass', 'b5ba49bbd92eb35ddb35b5acd039440d', '', now();
            INSERT INTO vote (editor, vote, vote_time, edit)
                SELECT generate_series(11, 15), 1, now(), 101;
            SQL
    }, $other_dbh->sql);

    my $c = $test->c->meta->clone_object($test->c, connector => $edit_queue_dbh);

    try {
        Sql::run_in_transaction(sub {
            # Acquire an exclusive lock on the edit
            $other_dbh->sql->select_single_row_array('SELECT * FROM edit WHERE id=101 FOR UPDATE');

            Sql::run_in_transaction(sub {
                # Try to apply an edit, but fail because it's being approved by
                # somebody on the website
                my $separate_queue = MusicBrainz::Server::EditQueue->new(
                    c => $c, log => $test->null_logger );

                my $errors = $separate_queue->process_edits;
                is($errors, 3, 'with errors');

                my $edit = $c->model('Edit')->get_by_id(101);
                is($edit->status, $STATUS_OPEN, 'still not changed');
            }, $edit_queue_dbh->sql);
        }, $other_dbh->sql);
    }
    finally {
        # Clean up
        Sql::run_in_transaction(sub {
            $other_dbh->sql->do('DELETE FROM edit_data');
            $other_dbh->sql->do('DELETE FROM vote');
            $other_dbh->sql->do('DELETE FROM edit');
            $other_dbh->sql->do('DELETE FROM editor');
        }, $other_dbh->sql);
    }
};

test 'Edit queue can close edits with sufficient yes votes early' => sub {
    my $test = shift;
    $test->c->sql->do(<<~"SQL");
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (10, 'Editor', '{CLEARTEXT}pass', 'b5ba49bbd92eb35ddb35b5acd039440d', '', now());
        INSERT INTO edit (id, editor, type, status, open_time, expire_time)
            VALUES (101, 10, $mock_class, 1, now() - interval '5 days', now() + interval '2 days');
        INSERT INTO edit_data (edit, data) VALUES (101, '{}');

        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            SELECT generate_series(11, 15), 'Voter ' || generate_series(1, 5), '{CLEARTEXT}pass', 'b5ba49bbd92eb35ddb35b5acd039440d', '', now();
        INSERT INTO vote (editor, vote, vote_time, edit)
            SELECT generate_series(11, 15), 1, now(), 101;
        SQL

    my $errors = $test->edit_queue->process_edits;
    is($errors, 0, 'without errors');

    my $edit = $test->c->model('Edit')->get_by_id(101);
    is($edit->status, $STATUS_APPLIED, 'applied');
};

test q(Edit queue won't close recent destructive edits even with sufficient yes votes) => sub {
    my $test = shift;
    $test->c->sql->do(<<~"SQL");
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (10, 'Editor', '{CLEARTEXT}pass', 'b5ba49bbd92eb35ddb35b5acd039440d', '', now());
        INSERT INTO edit (id, editor, type, status, open_time, expire_time)
            VALUES (101, 10, $mock_class, 1, now() - interval '3 hours', now() + interval '6 days 21 hours');
        INSERT INTO edit_data (edit, data) VALUES (101, '{}');

        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            SELECT generate_series(11, 15), 'Voter ' || generate_series(1, 5), '{CLEARTEXT}pass', 'b5ba49bbd92eb35ddb35b5acd039440d', '', now();
        INSERT INTO vote (editor, vote, vote_time, edit)
            SELECT generate_series(11, 15), 1, now(), 101;
        SQL

    my $errors = $test->edit_queue->process_edits;
    is($errors, 0, 'without errors');

    my $edit = $test->c->model('Edit')->get_by_id(101);
    is($edit->status, $STATUS_OPEN, 'still open');
};

test '_determine_new_status for different quality levels' => sub {
    my $test = shift;

    # Expired one day ago, without votes
    my $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(0);
    $edit->no_votes(0);
    $edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
    my $status = $test->edit_queue->_determine_new_status($edit);
    is($status, $STATUS_APPLIED, 'Normal quality edit with no votes passes on expiration');

    # Expired one day ago, 1 no vote, 0 yes votes
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(0);
    $edit->no_votes(1);
    $edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, $STATUS_FAILEDVOTE, 'Normal quality edit with No > Yes fails on expiration');

    # Expired one day ago, 0 no votes, 1 yes vote
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(1);
    $edit->no_votes(0);
    $edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, $STATUS_APPLIED, 'Normal quality edit with Yes > No passes on expiration');

    # Expired one day ago, 1 no vote, 1 yes vote
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(1);
    $edit->no_votes(1);
    $edit->expires_time(DateTime->now() - DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, $STATUS_FAILEDVOTE, 'Normal quality edit with Yes = No fails on expiration');

    # Not expired, without votes
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(0);
    $edit->no_votes(0);
    $edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, undef, 'Normal quality edit with no votes is left open before expiration');

    # Not expired, 3 yes votes, 0 no votes
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(3);
    $edit->no_votes(0);
    $edit->created_time(DateTime->now() - DateTime::Duration->new( days => 6 ));
    $edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, $STATUS_APPLIED, 'Normal quality edit with 3 Yes / 0 No passes before expiration');

    # Not expired, 0 yes votes, 3 no votes
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(0);
    $edit->no_votes(3);
    $edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, $STATUS_FAILEDVOTE, 'Normal quality edit with 0 Yes / 3 No fails before expiration');

    # Not expired, 2 yes votes, 0 no votes
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(2);
    $edit->no_votes(0);
    $edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, undef, 'Normal quality edit with fewer than 3 Yes votes stays open before expiration');

    # Not expired, 0 yes votes, 2 no votes
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(0);
    $edit->no_votes(2);
    $edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, undef, 'Normal quality edit with fewer than 3 No votes stays open before expiration');

    # Not expired, 3 yes votes, 1 no vote
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(3);
    $edit->no_votes(1);
    $edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, undef, 'Normal quality edit with 3 Yes / 1 No stays open before expiration');

    # Not expired, 1 yes vote, 3 no votes
    $edit = t::MusicBrainz::Server::EditQueue::MockEdit->new();
    $edit->yes_votes(1);
    $edit->no_votes(3);
    $edit->expires_time(DateTime->now() + DateTime::Duration->new( days => 1 ));
    $status = $test->edit_queue->_determine_new_status($edit);
    is($status, undef, 'Normal quality edit with 1 Yes / 3 No stays open before expiration');
};

1;
