use strict;
use warnings;
use Test::Exception;
use Test::More;
use Test::Moose;

BEGIN { use_ok 'Sql' }

use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+tag-truncate');
MusicBrainz::Server::Test->prepare_test_database($c, '+tag');

throws_ok { Sql->new } qr/Missing required argument 'dbh'/,
  'cannot create an Sql object with a database handle';

# Test
my $sql =
  new_ok('Sql', [ $c->dbh ], 'can create an Sql object with a database handle');

{
    # Check defaults
    has_attribute_ok($sql, 'dbh', 'dbh attribute');
    has_attribute_ok($sql, 'quiet', 'quiet attribute');
    can_ok($sql, qw( errstr quote finish row_count next_row next_row_ref next_row_hash_ref ));
    is($sql->quiet, 0, 'not quiet by default');
    is($sql->dbh, $c->dbh, 'make sure dbh is the same as whatever was passed in new');
    is($sql->_auto_commit, 0, 'dont autocommit by default');
    throws_ok { $sql->dbh('Blah') } qr/Cannot assign a value to a read-only accessor/, 'cannot change dbh';
    ok(!$sql->is_in_transaction, 'shouldnt be in a transaction');
}

{
    # Selection stuff
    my $rows = $sql->select("SELECT id, name FROM tag");
    is($rows, 4);
    is($sql->row_count, $rows);

    my @row = $sql->next_row;
    is_deeply(\@row, [ 1, 'musical' ], 'next_row should return array of next row');

    my $row = $sql->next_row_ref;
    is_deeply($row, [ 2, 'rock' ], 'next_row_ref should return array reference of next row');

    $row = $sql->next_row_hash_ref;
    is_deeply($row, { id => 3, name => 'jazz' }, 'next_row_hash_ref should return hash reference of next row');

    lives_ok { $sql->finish } 'should be able to finish statements';
}

{
    # Selection with bind parameters
    my $rows = $sql->select("SELECT id, name FROM tag WHERE id = ?", 1);
    is($rows, 1, 'where clause and bind parameters');

    my $row = $sql->next_row_hash_ref;
    is_deeply($row, { id => 1, name => 'musical' });

    $sql->finish;
}

{
    # Do with autocommit
    throws_ok { $sql->do('SELECT 1 from tag') }
        qr/do called while not in transaction, or marked to auto commit/,
            'must be in some sort of transaction';

    $sql->auto_commit(1);
    lives_ok { $sql->do('SELECT 1 from tag') } 'can do queries with auto commit';
    is($sql->_auto_commit, 0, 'do should invalidate autocommit');

    $sql->auto_commit(1);
    lives_ok { $sql->do('SELECT 1 from tag WHERE id = ?', 1) } 'can do queries with binds';

    $sql->auto_commit(1);
    dies_ok { $sql->do('Absolute nonsense') } 'do throws on an SQL exception';
    is($sql->_auto_commit, 0, 'autocommit is changed for bad SQL statements');
}

{
    # Inserting rows
    $sql->_auto_commit(0);
    throws_ok { $sql->insert_row('tag', { id => 5, name => 'magical' }) }
        qr/do called while not in transaction, or marked to auto commit/,
            'must be in some sort of transaction';

    $sql->auto_commit(1);
    throws_ok { $sql->insert_row('tag', { }) }
        qr/Cannot insert a missing or empty row/;

    $sql->auto_commit(1);
    lives_ok { $sql->insert_row('tag', { id => 5, name => 'magical' }) } 'can insert rows';
    my $rows = $sql->select_single_value('SELECT count(*) FROM tag WHERE id = ?', 5);
    is($rows, 1);

    my $id;
    $sql->auto_commit(1);
    lives_ok { $id = $sql->insert_row('tag', { id => 6, name => 'live' }, 'id') } 'can insert returning';
    is($id, 6, 'can insert returning id');
    $rows = $sql->select_single_value('SELECT count(*) FROM tag WHERE id = ?', 6);
    is($rows, 1);

    $sql->auto_commit(1);
    lives_ok { $id = $sql->insert_row('tag', { id => 7, name => \"'calm'" }) } 'can insert with literal sql';
    $rows = $sql->select_single_value('SELECT count(*) FROM tag WHERE id = ?', 7);
    is($rows, 1);
}

{
    # Updating rows
    $sql->_auto_commit(0);
    throws_ok { $sql->update_row('tag', { name => 'magic' }, { id => 5 }) }
        qr/do called while not in transaction, or marked to auto commit/,
            'must be in some sort of transaction';

    $sql->auto_commit(1);
    throws_ok { $sql->update_row('tag', { name => 'foo' }) }
        qr/update_row called with no where clause/,
            'must pass where clause';

    $sql->auto_commit(1);
    lives_ok { $sql->update_row('tag', { name => 'magic' }, { id => 5 }) } 'can update rows';
    my $rows = $sql->select_single_value('SELECT count(*) FROM tag WHERE name = ?', 'magic');
    is($rows, 1);
}

{
    # Transaction handling
    lives_ok { $sql->begin } 'can enter a transaction';
    ok($sql->is_in_transaction);

    lives_ok { $sql->begin } 'can nest begin calls';
    ok($sql->is_in_transaction);

    lives_ok { $sql->commit } 'can commit';
    ok($sql->is_in_transaction, 'remains in transaction');

    lives_ok { $sql->commit } 'can commit';

    ok(!$sql->is_in_transaction);
    throws_ok { $sql->commit } qr/commit called without begin/,
        'Cannot commit while not in a transaction';

    lives_ok { $sql->begin };
    lives_ok { $sql->rollback } 'can rollback a transaction';

    ok(!$sql->is_in_transaction);
    throws_ok { $sql->rollback } qr/rollback called without begin/,
        'Cannot rollback while not in a transaction';
}

{
    # Test automatic transactions
    my $sub = sub {
        $sql->update_row('tag', { name => 'blah' }, { id => 5 });
        my $rows = $sql->select_single_value('SELECT count(*) FROM tag WHERE name = ?', 'blah');
        is($rows, 1);
    };

    lives_ok {
        $sql->auto_transaction($sub);
    } 'can call automatic transactions on a single sql object';

    lives_ok { Sql::run_in_transaction($sub, $sql) } 'can call run_in_transaction';
}

{
    # Selecting single values
    lives_and {
        is_deeply($sql->select_single_row_hash('SELECT id,name FROM tag WHERE id = 1'),
              { name => 'musical', id => 1 })
    } 'select_single_row_hash with SQL';

    lives_and {
        is_deeply($sql->select_single_row_hash('SELECT id,name FROM tag WHERE id = ?', 1),
              { name => 'musical', id => 1 })
    } 'select_single_row_hash with bind parameters';

    lives_and {
        is_deeply($sql->select_single_row_array('SELECT id,name FROM tag WHERE id = 1'),
              [ 1, 'musical' ])
    } 'select_single_row_array with SQL';

    lives_and {
        is_deeply($sql->select_single_row_array('SELECT id,name FROM tag WHERE id = ?', 1),
              [ 1, 'musical' ])
    } 'select_single_row_array with bind parameters';

    lives_and {
        is_deeply($sql->select_single_column_array('SELECT id FROM tag WHERE id = 1'),
              [ 1 ])
    } 'select_single_column_array with SQL';

    lives_and {
        is_deeply($sql->select_single_column_array('SELECT id FROM tag WHERE id = ?', 1),
              [ 1 ])
    } 'select_single_column_array with bind parameters';

    lives_and {
        is_deeply($sql->select_single_column_array('SELECT id FROM tag WHERE id > ?', 5),
              [ 6, 7 ])
    } 'select_single_column_array with bind parameters';

    throws_ok {
        $sql->select_single_column_array('SELECT id,name FROM tag WHERE id = ?', 1)
    } qr/Query returned multiple columns/, 'select_single_column_array with bind parameters';

    lives_and {
        is($sql->select_single_value('SELECT id FROM tag WHERE id = 1'), 1)
    } 'select_single_value with SQL';

    lives_and {
        is($sql->select_single_value('SELECT id FROM tag WHERE id = ?', 1), 1)
    } 'select_single_value with bind parameters';
}

{
    # Selecting lists
    lives_and {
        is_deeply($sql->select_list_of_lists('SELECT id,name FROM tag WHERE id IN (1,2) ORDER BY id ASC'),
                  [[1, 'musical'], [2, 'rock']]);
    } 'select_list_of_lists with SQL';

    lives_and {
        is_deeply($sql->select_list_of_lists('SELECT id,name FROM tag WHERE id IN (?,?) ORDER BY id ASC', 1, 2),
                  [[1, 'musical'], [2, 'rock']]);
    } 'select_list_of_lists with bind paremeters';
}

{
    # Selecting list of hashes
    lives_and {
        is_deeply($sql->select_list_of_hashes('SELECT id,name FROM tag WHERE id IN (1,2) ORDER BY id ASC'),
                  [
                      { id => 1, name => 'musical' },
                      { id => 2, name => 'rock' }
                  ]);
    } 'select_list_of_hashes with SQL';

    lives_and {
        is_deeply($sql->select_list_of_hashes('SELECT id,name FROM tag WHERE id IN (?,?) ORDER BY id ASC', 1, 2),
                  [
                      { id => 1, name => 'musical' },
                      { id => 2, name => 'rock' }
                  ]);
    } 'select_list_of_hashes with bind parameters';
}

{
    lives_and {
        my @range = $sql->get_column_range('tag', 'id');
        is_deeply(\@range, [ 1, 7 ])
    } 'get_column_range in list context';
}

{
    # Clean up!
    $sql->auto_commit(1);
    $sql->do('TRUNCATE tag CASCADE');
}

done_testing;
