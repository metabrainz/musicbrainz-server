use strict;
use warnings;

use DBDefs;
use lib 't/lib';
use Test::More;
use Test::Routine;
use Test::Routine::Util;
use Test::Deep qw( cmp_deeply ignore );
use utf8;

use DBDefs;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;
use aliased 't::script::ReplicationTest';

test all => sub {
    my $test = ReplicationTest->new;
    my $master_c = $test->master_c;
    my $mirror_c = $test->mirror_c;

    my $create_schema_query = <<~"SQL";
        BEGIN;
        CREATE TABLE json_column_test (id SMALLINT, c1 JSON, c2 JSONB, c3 JSON[], c4 JSONB[]);
        ALTER TABLE json_column_test ADD CONSTRAINT json_column_test_pkey PRIMARY KEY (id);
        -- Skip past special purpose artists.
        SELECT setval('artist_id_seq', 3, FALSE);
        COMMIT;
        SQL
    $master_c->sql->auto_commit;
    $master_c->sql->do($create_schema_query);

    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        CREATE TRIGGER reptg2_json_column_test
            AFTER INSERT OR DELETE OR UPDATE ON json_column_test
            FOR EACH ROW EXECUTE PROCEDURE dbmirror2.recordchange();
        SQL

    $mirror_c->sql->auto_commit;
    $mirror_c->sql->do($create_schema_query);

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
        $master_c->sql->do(<<~'SQL');
            INSERT INTO json_column_test
                 VALUES (1, '[1]', '[1]', '{"[1]"}'::JSON[], '{"[1]"}'::JSONB[]);
            UPDATE json_column_test
               SET c1 = '{"c1":[1]}',
                   c2 = '{"c2":[1]}',
                   c3 = '{{"{\"c3\":[1]}"},{"{\"c3\":[2]}"}}'::JSON[],
                   c4 = '{{"{\"c4\":[1]}"},{"{\"c4\":[2]}"}}'::JSONB[]
             WHERE id = 1;
            SQL

        # test that editor data is not replicated
        $master_c->sql->do(<<~'SQL');
            INSERT INTO editor (id, name, password, ha1)
                 VALUES (909, 'ZZZ', '{CLEARTEXT}mb', '');
            SQL
    }, $master_c->sql);

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );
    $test->load_replication_changes;

    $new_artist = $mirror_c->sql->select_single_row_hash(
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
        name => "\x{677e}", ## no critic (ProhibitEscapedCharacters) - unassigned/unnamed character
        sort_name => '{\\"abc\\": 123}',
        type => undef,
    });

    $to_be_deleted_artist = $mirror_c->sql->select_single_row_hash(
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

    my $json_test_row = $mirror_c->sql->select_single_row_hash(
        'SELECT * FROM json_column_test WHERE id = 1',
    );
    is($json_test_row->{c1}, '{"c1":[1]}');
    is($json_test_row->{c2}, '{"c2": [1]}');
    cmp_deeply($json_test_row->{c3}, [['{"c3":[1]}'], ['{"c3":[2]}']]);
    cmp_deeply($json_test_row->{c4}, [['{"c4": [1]}'], ['{"c4": [2]}']]);

    my $editor_row = $mirror_c->sql->select_single_row_hash('SELECT * FROM editor WHERE id = 909');
    is($editor_row, undef, 'editor is not replicated');

    Sql::run_in_transaction(sub {
        $master_c->model('Artist')->delete($to_be_deleted_artist->{id});

        # test json columns too
        $master_c->sql->do(<<~'SQL');
            DELETE FROM json_column_test WHERE id = 1;
            SQL
    }, $master_c->sql);

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );
    $test->load_replication_changes;

    $to_be_deleted_artist = $mirror_c->sql->select_single_row_hash(
        'SELECT * FROM artist WHERE id = ?',
        $to_be_deleted_artist->{id},
    );
    ok(!defined $to_be_deleted_artist);

    $json_test_row = $mirror_c->sql->select_single_row_hash(
        'SELECT * FROM json_column_test WHERE id = 1',
    );
    ok(!defined $json_test_row);
};

run_me;
done_testing;

1;

