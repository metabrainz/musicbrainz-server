package t::Sql;
use Test::Routine;
use Test::More;
use Test::Fatal;
use Test::Moose;

use Sql;
use Try::Tiny;

with 't::Context';

test 'Cannot create Sql objects without a dbh' => sub {
    like(exception { Sql->new }, qr/Missing required argument 'conn'/,
        'cannot create a Sql object without a database connector');
};

test 'Nest select_single_column_array in select' => sub {
    my $test = shift;
    my $sql = $test->c->sql;

    $sql->select(q(SELECT * FROM (VALUES (1, 'musical'), (2, 'rock')) tag (id, name)));
    is exception {
        while ($sql->next_row_ref) {
            $sql->select_single_column_array('SELECT * FROM generate_series(1, 10)');
        }
    }, undef;
};

test 'Nest select_single_row_array in select' => sub {
    my $test = shift;
    my $sql = $test->c->sql;

    $sql->select(q(SELECT * FROM (VALUES (1, 'musical'), (2, 'rock')) tag (id, name)));
    is exception {
        while ($sql->next_row_ref) {
            $sql->select_single_row_array('SELECT * FROM generate_series(1, 10) LIMIT 1');
        }
    }, undef;
};

test 'All tests' => sub {
    my $test = shift;

    my $other_dbh = MusicBrainz::Server::DatabaseConnectionFactory->get_connection('TEST', fresh => 1);

    my $sql = new_ok('Sql', [ $other_dbh->conn ], 'can create an Sql object with a connector');

    {
        # Check defaults
        has_attribute_ok($sql, 'conn', 'conn attribute');
        has_attribute_ok($sql, 'quiet', 'quiet attribute');
        can_ok($sql, qw( finish row_count next_row next_row_ref next_row_hash_ref ));
        is($sql->quiet, 0, 'not quiet by default');
        is($sql->conn, $other_dbh->conn, 'make sure dbh is the same as whatever was passed in new');
        is($sql->_auto_commit, 0, 'dont autocommit by default');
        like(exception { $sql->conn('Blah') }, qr/Cannot assign a value to a read-only accessor/, 'cannot change dbh');
        ok(!$sql->is_in_transaction, 'shouldnt be in a transaction');
    }

    {
        # Selection stuff
        my $rows = $sql->select(q(SELECT * FROM (VALUES (1, 'musical'), (2, 'rock'), (3, 'jazz'), (4, 'foo')) tag (id, name)));
        is($rows, 4);
        is($sql->row_count, $rows);

        my @row = $sql->next_row;
        is_deeply(\@row, [ 1, 'musical' ], 'next_row should return array of next row');

        my $row = $sql->next_row_ref;
        is_deeply($row, [ 2, 'rock' ], 'next_row_ref should return array reference of next row');

        $row = $sql->next_row_hash_ref;
        is_deeply($row, { id => 3, name => 'jazz' }, 'next_row_hash_ref should return hash reference of next row');

        ok(!exception { $sql->finish }, 'should be able to finish statements');
    }

    {
        # Selection with bind parameters
        my $rows = $sql->select(q(SELECT id, name FROM (VALUES (1, 'musical') ) tag(id, name) WHERE id = ?), 1);
        is($rows, 1, 'where clause and bind parameters');

        my $row = $sql->next_row_hash_ref;
        is_deeply($row, { id => 1, name => 'musical' });

        $sql->finish;
    }

    {
        # Do with autocommit
        like(exception { $sql->do('SELECT 1 FROM tag') },
           qr/do called while not in transaction, or marked to auto commit/,
           'must be in some sort of transaction');

        $sql->auto_commit(1);
        ok !exception { $sql->do('SELECT 1 FROM tag') }, 'can do queries with auto commit';
        is($sql->_auto_commit, 0, 'do should invalidate autocommit');

        $sql->auto_commit(1);
        ok !exception { $sql->do('SELECT 1 FROM tag WHERE id = ?', 1) }, 'can do queries with binds';

        $sql->auto_commit(1);
        ok exception { $sql->do('Absolute nonsense') }, 'do throws on an SQL exception';
        is($sql->_auto_commit, 0, 'autocommit is changed for bad SQL statements');
    }

    try {
        # Inserting rows
        $sql->_auto_commit(0);
        like exception { $sql->insert_row('tag', { id => 5, name => 'magical' }) },
            qr/do called while not in transaction, or marked to auto commit/,
                'must be in some sort of transaction';

        $sql->auto_commit(1);
        like exception { $sql->insert_row('tag', { }) },
            qr/Cannot insert a missing or empty row/;

        $sql->auto_commit(1);
        ok !exception { $sql->insert_row('artist_type', { id => 7, gid => 'c7ac3831-739d-11de-8a39-0800200c9a68', name => 'magical' }) }, 'can insert rows';
        my $rows = $sql->select_single_value('SELECT count(*) FROM artist_type WHERE id = ?', 7);
        is($rows, 1);

        my $id;
        $sql->auto_commit(1);
        ok !exception { $id = $sql->insert_row('artist_type', { id => 8, gid => 'c8ac3831-739d-11de-8a39-0800200c9a68', name => 'live' }, 'id') }, 'can insert returning';
        is($id, 8, 'can insert returning id');
        $rows = $sql->select_single_value('SELECT count(*) FROM artist_type WHERE id = ?', 8);
        is($rows, 1);

        $sql->auto_commit(1);
        ok !exception { $id = $sql->insert_row('artist_type', { id => 9, gid => 'c9ac3831-739d-11de-8a39-0800200c9a68', name => \q('calm') }) }, 'can insert with literal sql';
        $rows = $sql->select_single_value('SELECT count(*) FROM artist_type WHERE id = ?', 9);
        is($rows, 1);

        # Updating rows
        $sql->_auto_commit(0);
        like exception { $sql->update_row('tag', { name => 'magic' }, { id => 7 }) },
            qr/do called while not in transaction, or marked to auto commit/,
                'must be in some sort of transaction';

        $sql->auto_commit(1);
        like exception { $sql->update_row('tag', { name => 'foo' }) },
            qr/update_row called with no where clause/,
                'must pass where clause';

        $sql->auto_commit(1);
        ok !exception { $sql->update_row('artist_type', { name => 'magic' }, { id => 7 }) }, 'can update rows';
        $rows = $sql->select_single_value('SELECT count(*) FROM artist_type WHERE name = ?', 'magic');
        is($rows, 1);

        # Test automatic transactions
        my $sub = sub {
            $sql->update_row('artist_type', { name => 'blah' }, { id => 7 });
            my $rows = $sql->select_single_value('SELECT count(*) FROM artist_type WHERE name = ?', 'blah');
            is($rows, 1);
        };

        ok !exception {
            $sql->auto_transaction($sub);
        }, 'can call automatic transactions on a single sql object';

        ok !exception { Sql::run_in_transaction($sub, $sql) }, 'can call run_in_transaction';
    }
    finally {
        $sql->auto_commit(1);
        $sql->do('DELETE FROM artist_type WHERE id IN (7, 8, 9)');

        $sql->auto_commit(1);
        $sql->do('DELETE FROM tag');
    };

    {
        # Transaction handling
        ok !exception { $sql->begin }, 'can enter a transaction';
        ok($sql->is_in_transaction);

        ok !exception { $sql->begin }, 'can nest begin calls';
        ok($sql->is_in_transaction);

        ok !exception { $sql->commit }, 'can commit';
        ok($sql->is_in_transaction, 'remains in transaction');

        ok !exception { $sql->commit }, 'can commit';

        ok(!$sql->is_in_transaction);
        like exception { $sql->commit }, qr/commit called without begin/,
            'Cannot commit while not in a transaction';

        ok !exception { $sql->begin };
        ok !exception { $sql->rollback }, 'can rollback a transaction';

        ok(!$sql->is_in_transaction);
        like exception { $sql->rollback }, qr/rollback called without begin/,
            'Cannot rollback while not in a transaction';
    }

    {
        # Selecting single values
        ok !exception {
            is_deeply($sql->select_single_row_hash(q(SELECT id,name FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = 1)),
                      { name => 'musical', id => 1 })
        }, 'select_single_row_hash with SQL';

        ok !exception {
            is_deeply($sql->select_single_row_hash(q(SELECT id,name FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = ?), 1),
                      {
                          name => 'musical', id => 1 })
        }, 'select_single_row_hash with bind parameters';

        ok !exception {
            is_deeply($sql->select_single_row_array(q(SELECT id,name FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = 1)),
                      [ 1, 'musical' ])
        }, 'select_single_row_array with SQL';

        ok !exception {
            is_deeply($sql->select_single_row_array(q(SELECT id,name FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = ?), 1),
                      [ 1, 'musical' ])
        }, 'select_single_row_array with bind parameters';

        ok !exception {
            is_deeply($sql->select_single_column_array(q(SELECT id FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = 1)),
                      [ 1 ])
        }, 'select_single_column_array with SQL';

        ok !exception {
            is_deeply($sql->select_single_column_array(q(SELECT id FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = ?), 1),
                      [ 1 ])
        }, 'select_single_column_array with bind parameters';

        ok !exception {
            is_deeply($sql->select_single_column_array(q(SELECT id FROM (VALUES (6, 'musical'), (7, 'rock')) tag (id, name) WHERE id > ?), 5),
                      [ 6, 7 ])
        }, 'select_single_column_array with bind parameters';

        like exception {
            $sql->select_single_column_array(q(SELECT id,name FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = 1))
        }, qr/Query returned multiple columns/, 'select_single_column_array with bind parameters';

        ok !exception {
            is($sql->select_single_value(q(SELECT id FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = 1)), 1)
        }, 'select_single_value with SQL';

        ok !exception {
            is($sql->select_single_value(q(SELECT id FROM (VALUES (1, 'musical')) tag (id, name) WHERE id = ?), 1), 1)
        }, 'select_single_value with bind parameters';
    }

    {
        # Selecting lists
        ok !exception {
            is_deeply($sql->select_list_of_lists(q(SELECT id,name FROM (VALUES (1, 'musical'), (2, 'rock')) tag (id, name) WHERE id IN (1,2) ORDER BY id ASC)),
                      [[1, 'musical'], [2, 'rock']]);
        }, 'select_list_of_lists with SQL';

        ok !exception {
            is_deeply($sql->select_list_of_lists(q(SELECT id,name FROM (VALUES (1, 'musical'), (2, 'rock')) tag (id, name) WHERE id IN (?,?) ORDER BY id ASC), 1, 2),
                      [[1, 'musical'], [2, 'rock']]);
        }, 'select_list_of_lists with bind paremeters';
    }

    {
        # Selecting list of hashes
        ok !exception {
            is_deeply($sql->select_list_of_hashes(q(SELECT id,name FROM (VALUES (1, 'musical'), (2, 'rock')) tag (id, name) WHERE id IN (1,2) ORDER BY id ASC)),
                      [
                          {
                              id => 1, name => 'musical' },
                          {
                              id => 2, name => 'rock' }
                      ]);
        }, 'select_list_of_hashes with SQL';

        ok !exception {
            is_deeply($sql->select_list_of_hashes(q(SELECT id,name FROM (VALUES (1, 'musical'), (2, 'rock')) tag (id, name) WHERE id IN (?,?) ORDER BY id ASC), 1, 2),
                      [
                          {
                              id => 1, name => 'musical' },
                          {
                              id => 2, name => 'rock' }
                      ]);
        }, 'select_list_of_hashes with bind parameters';
    }
};

1;
