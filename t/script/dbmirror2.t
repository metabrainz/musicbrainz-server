use strict;
use warnings;

use DBDefs;
use File::Spec;
use File::Temp qw( tempdir );
use String::ShellQuote;
use Test::More;
use Test::Routine;
use Test::Routine::Util;
use Test::Deep qw( cmp_deeply ignore );
use MusicBrainz::Server::Test;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';
use Sql;
use utf8;

test all => sub {
    my $master_c = MusicBrainz::Server::Context->create_script_context(
        database => 'TEST_DBMIRROR2_MASTER',
    );

    my $slave_c = MusicBrainz::Server::Context->create_script_context(
        database => 'TEST_DBMIRROR2_SLAVE',
    );

    my $root = DBDefs->MB_SERVER_ROOT;
    my $psql = File::Spec->catfile($root, 'admin/psql');

    my $exec_sql = sub {
        my ($raw_db_name, $raw_sql) = @_;

        my $db_name = shell_quote($raw_db_name);
        my $sql = shell_quote($raw_sql);

        system 'sh', '-c' => "echo $sql | $psql $db_name";
    };

    my $system_db = Databases->get('SYSTEM');
    my $master_db = Databases->get('TEST_DBMIRROR2_MASTER');
    my $slave_db = Databases->get('TEST_DBMIRROR2_SLAVE');

    $ENV{PGPASSWORD} = $master_db->password;

    system 'dropdb',
        '--if-exists',
        '--host', $master_db->host,
        '--port', $master_db->port,
        '--username', $system_db->username,
        $master_db->database;

    system 'dropdb',
        '--if-exists',
        '--host', $slave_db->host,
        '--port', $slave_db->port,
        '--username', $system_db->username,
        $slave_db->database;

    system(
        File::Spec->catfile($root, 'admin/InitDb.pl'),
        '--createdb',
        '--database', 'TEST_DBMIRROR2_MASTER',
        '--dbmirror2',
        '--clean',
        '--reptype', '1',
    );

    system(
        File::Spec->catfile($root, 'admin/InitDb.pl'),
        '--createdb',
        '--database', 'TEST_DBMIRROR2_SLAVE',
        '--dbmirror2',
        '--clean',
        '--reptype', '2',
    );

    my $schema_seq = DBDefs->DB_SCHEMA_SEQUENCE;
    my $replication_control_query = <<~"SQL";
        BEGIN;
        UPDATE replication_control
           SET current_schema_sequence = $schema_seq,
               current_replication_sequence = 1,
               last_replication_date = '2021-10-01 01:01:01.123456+00';
        TRUNCATE dbmirror2.pending_keys CASCADE;
        TRUNCATE dbmirror2.pending_data CASCADE;
        TRUNCATE dbmirror2.pending_ts CASCADE;
        CREATE TABLE json_column_test (id SMALLINT, c1 JSON, c2 JSONB, c3 JSON[], c4 JSONB[]);
        ALTER TABLE json_column_test ADD CONSTRAINT json_column_test_pkey PRIMARY KEY (id);
        COMMIT;
        SQL
    $exec_sql->('TEST_DBMIRROR2_MASTER', $replication_control_query);
    $exec_sql->('TEST_DBMIRROR2_MASTER', <<~'SQL');
        REFRESH MATERIALIZED VIEW dbmirror2.column_info;
        CREATE TRIGGER reptg2_json_column_test
            AFTER INSERT OR DELETE OR UPDATE ON json_column_test
            FOR EACH ROW EXECUTE PROCEDURE dbmirror2.recordchange();
        SQL
    $exec_sql->('TEST_DBMIRROR2_SLAVE', $replication_control_query);

    my $new_artist;
    my $to_be_deleted_artist;
    Sql::run_in_transaction(sub {
        $new_artist = $master_c->model('Artist')->insert({
            name => '松',
            sort_name => '{\\"abc\\": 123}',
        });

        $to_be_deleted_artist = $master_c->model('Artist')->insert({
            name => 'delete me',
            sort_name => 'me, delete',
        });
    }, $master_c->sql);

    Sql::run_in_transaction(sub {
        $master_c->model('Artist')->update($new_artist->{id}, {
            comment => 'test',
        });

        # test a no-op update
        $master_c->model('Artist')->update($new_artist->{id}, {
            comment => 'test',
        });
    }, $master_c->sql);

    Sql::run_in_transaction(sub {
        # add a cdtoc to test integer arrays (track_offset)
        $master_c->model('CDTOC')->find_or_insert('1 2 157005 150 77950');

        # test json columns too
        $exec_sql->('TEST_DBMIRROR2_MASTER', <<~'SQL');
            INSERT INTO json_column_test
                 VALUES (1, '[1]', '[1]', '{"[1]"}'::JSON[], '{"[1]"}'::JSONB[]);
            UPDATE json_column_test
               SET c1 = '{"c1":[1]}',
                   c2 = '{"c2":[1]}',
                   c3 = '{{"{\"c3\":[1]}"},{"{\"c3\":[2]}"}}'::JSON[],
                   c4 = '{{"{\"c4\":[1]}"},{"{\"c4\":[2]}"}}'::JSONB[]
             WHERE id = 1;
            SQL
    }, $master_c->sql);

    my $output_dir = tempdir('t-dbmirror2-XXXXXXXX', DIR => '/tmp', CLEANUP => 1);

    my $export_all_tables = sub {
        system (
            File::Spec->catfile($root, 'admin/ExportAllTables'),
            '--without-full-export',
            '--with-replication',
            '--output-dir', $output_dir,
            '--database', 'TEST_DBMIRROR2_MASTER',
            '--compress',
        );
    };

    my $load_replication_tables = sub {
        system (
            File::Spec->catfile($root, 'admin/replication/LoadReplicationChanges'),
            '--base-uri', 'file://' . $output_dir,
            '--database', 'TEST_DBMIRROR2_SLAVE',
            '--dbmirror2',
            '--lockfile', '/tmp/.mb-LoadReplicationChanges-TEST_DBMIRROR2_SLAVE',
        );
    };

    $export_all_tables->();
    $load_replication_tables->();

    $new_artist = $slave_c->sql->select_single_row_hash(
        'SELECT * FROM artist WHERE id = ?',
        $new_artist->{id},
    );

    cmp_deeply($new_artist, {
        area => undef,
        begin_area => undef,
        begin_date_day => undef,
        begin_date_month => undef,
        begin_date_year => undef,
        comment => 'test',
        edits_pending => 0,
        end_area => undef,
        end_date_day => undef,
        end_date_month => undef,
        end_date_year => undef,
        ended => 0,
        gender => undef,
        gid => ignore(),
        id => $new_artist->{id},
        last_updated => ignore(),
        name => "\x{677e}",
        sort_name => '{\\"abc\\": 123}',
        type => undef,
    });

    $to_be_deleted_artist = $slave_c->sql->select_single_row_hash(
        'SELECT * FROM artist WHERE id = ?',
        $to_be_deleted_artist->{id},
    );

    cmp_deeply($to_be_deleted_artist, {
        area => undef,
        begin_area => undef,
        begin_date_day => undef,
        begin_date_month => undef,
        begin_date_year => undef,
        comment => '',
        edits_pending => 0,
        end_area => undef,
        end_date_day => undef,
        end_date_month => undef,
        end_date_year => undef,
        ended => 0,
        gender => undef,
        gid => ignore(),
        id => $to_be_deleted_artist->{id},
        last_updated => ignore(),
        name => 'delete me',
        sort_name => 'me, delete',
        type => undef,
    });

    my $json_test_row = $slave_c->sql->select_single_row_hash(
        'SELECT * FROM json_column_test WHERE id = 1',
    );
    is($json_test_row->{c1}, '{"c1":[1]}');
    is($json_test_row->{c2}, '{"c2": [1]}');
    cmp_deeply($json_test_row->{c3}, [['{"c3":[1]}'], ['{"c3":[2]}']]);
    cmp_deeply($json_test_row->{c4}, [['{"c4": [1]}'], ['{"c4": [2]}']]);

    Sql::run_in_transaction(sub {
        $master_c->model('Artist')->delete($to_be_deleted_artist->{id});

        # test json columns too
        $exec_sql->('TEST_DBMIRROR2_MASTER', <<~'SQL');
            DELETE FROM json_column_test WHERE id = 1;
            SQL
    }, $master_c->sql);

    $export_all_tables->();
    $load_replication_tables->();

    $to_be_deleted_artist = $slave_c->sql->select_single_row_hash(
        'SELECT * FROM artist WHERE id = ?',
        $to_be_deleted_artist->{id},
    );
    ok(!defined $to_be_deleted_artist);

    $json_test_row = $slave_c->sql->select_single_row_hash(
        'SELECT * FROM json_column_test WHERE id = 1',
    );
    ok(!defined $json_test_row);
};

run_me;
done_testing;
