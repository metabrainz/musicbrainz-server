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
use utf8;

test all => sub {
    # Because this test invokes external scripts that rely on certain test data
    # existing, it can't use t::Context or anything that would be contained
    # inside a transaction.

    my $root = DBDefs->MB_SERVER_ROOT;
    my $psql = File::Spec->catfile($root, 'admin/psql');

    my $exec_sql = sub {
        my $sql = shell_quote(shift);

        system 'sh', '-c' => "echo $sql | $psql TEST_FULL_EXPORT";
    };

    my $output_dir = tempdir("t-fullexport-XXXXXXXX", DIR => '/tmp', CLEANUP => 1);
    my $schema_seq = DBDefs->DB_SCHEMA_SEQUENCE;

    # MBS-9342
    my $long_unicode_tag1 = '松' x 255;
    my $long_unicode_tag2 = '変' x 255;

    $exec_sql->(<<~"EOSQL");
        BEGIN;
        INSERT INTO replication_control (current_schema_sequence, current_replication_sequence, last_replication_date)
            VALUES ($schema_seq, 1, now() - interval '1 hour');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (666, '30238ead-59fa-41e2-a7ab-b7f6e6363c4b', 'A', 'A');
        INSERT INTO tag (id, name, ref_count)
            VALUES (1, '$long_unicode_tag1', 1);
        INSERT INTO artist_tag (artist, tag, count, last_updated)
            VALUES (666, 1, 1, now());
        INSERT INTO area (
            id, gid, name, type, edits_pending, last_updated, begin_date_year,
            begin_date_month, begin_date_day, end_date_year, end_date_month,
            end_date_day, ended, comment
        ) VALUES (
            5099, '29a709d8-0320-493e-8d0c-f2c386662b7f', 'Chicago', 3, 0,
            '2013-05-24 20:27:13.405462+00', NULL, NULL, NULL, NULL, NULL, NULL,
            'f', ''
        );
        INSERT INTO editor (
            name, privs, email, website, bio, member_since, email_confirm_date,
            last_login_date, last_updated, birth_date, gender, area, password,
            ha1, deleted
        ) VALUES (
            'false_editor', 937, 'false_editor123\@example.com',
            'false_editor123.example.com', 'hi im false',
            '2020-11-26 01:13:41.810622+00', '2020-11-26 01:13:57.82052+00',
            '2020-11-26 01:19:11.752133+00', '2020-11-26 01:13:41.810622+00',
            '1970-01-20', 3, 5099, '{CRYPT}abc123secret',
            '35c1f5f73559130eddbef34e50e22ad6', 'f'
        );
        COMMIT;
        EOSQL

    system (
        File::Spec->catfile($root, 'admin/ExportAllTables'),
        '--with-full-export',
        '--without-replication',
        '--output-dir', $output_dir,
        '--database', 'TEST_FULL_EXPORT',
        '--compress',
    );

    my $quoted_output_dir = shell_quote($output_dir);
    system("cd $quoted_output_dir && md5sum -c MD5SUMS") == 0
        or die $!;
    system("cd $quoted_output_dir && sha256sum -c SHA256SUMS") == 0
        or die $!;

    $exec_sql->(<<~"EOSQL");
        SET client_min_messages TO WARNING;
        INSERT INTO dbmirror_pending
            VALUES (1, '"musicbrainz"."artist"', 'i', 1),
                   (2, '"musicbrainz"."artist"', 'u', 2),
                   (3, '"musicbrainz"."tag"', 'i', 3),
                   (4, '"musicbrainz"."artist_tag"', 'i', 3);
        INSERT INTO dbmirror_pendingdata
            VALUES (1, 'f', '"id"=''667'' "gid"=''b3d9590e-cd28-47a9-838a-ed41a78002f5'' "name"=''B'' "sort_name"=''B'' "last_updated"=''2016-05-03 20:00:00+00'' '),
                   (2, 't', '"id"=''666'' '),
                   (2, 'f', '"name"=''Updated A'' '),
                   (3, 'f', '"id"=''2'' "name"=''$long_unicode_tag2'' "ref_count"=''1'' '),
                   (4, 'f', '"artist"=''667'' "tag"=''2'' "count"=''1'' "last_updated"=''2016-05-03 20:00:00+00'' ');
        EOSQL

    system (
        File::Spec->catfile($root, 'admin/ExportAllTables'),
        '--without-full-export',
        '--with-replication',
        '--output-dir', $output_dir,
        '--database', 'TEST_FULL_EXPORT',
        '--compress',
    );

    my $system_db = Databases->get('SYSTEM');
    my $test_db = Databases->get('TEST_FULL_EXPORT');
    $ENV{PGPASSWORD} = $test_db->password;
    system 'dropdb',
        '-h', $test_db->host,
        '-p', $test_db->port,
        '-U', $system_db->username,
        $test_db->database;

    system(
        File::Spec->catfile($root, 'admin/InitDb.pl'),
        '--database', 'TEST_FULL_EXPORT',
        '--createdb',
        '--import',
            File::Spec->catfile($output_dir, 'mbdump.tar.bz2'),
            File::Spec->catfile($output_dir, 'mbdump-derived.tar.bz2'),
            File::Spec->catfile($output_dir, 'mbdump-editor.tar.bz2'),
    );

    my $replication_setup = File::Spec->catfile($root, 'admin/sql/ReplicationSetup.sql');
    system 'sh', '-c' => "$psql TEST_FULL_EXPORT < $replication_setup";

    $exec_sql->(<<~"EOSQL");
        SET client_min_messages TO WARNING;
        TRUNCATE replication_control CASCADE;
        INSERT INTO replication_control (current_schema_sequence, current_replication_sequence, last_replication_date)
            VALUES ($schema_seq, 1, now() - interval '1 hour');
        EOSQL

    system (
        File::Spec->catfile($root, 'admin/replication/LoadReplicationChanges'),
        '--base-uri', 'file://' . $output_dir,
        '--database', 'TEST_FULL_EXPORT',
        '--lockfile', '/tmp/.mb-LoadReplicationChanges-TEST_FULL_EXPORT',
    );

    my $c = MusicBrainz::Server::Context->create_script_context(database => 'TEST_FULL_EXPORT');
    my $artists = $c->sql->select_list_of_hashes('SELECT * FROM artist ORDER BY id');

    cmp_deeply($artists, [
        {
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
            gid => '30238ead-59fa-41e2-a7ab-b7f6e6363c4b',
            id => 666,
            last_updated => ignore(),
            name => 'Updated A',
            sort_name => 'A',
            type => undef,
        },
        {
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
            gid => 'b3d9590e-cd28-47a9-838a-ed41a78002f5',
            id => 667,
            last_updated => ignore(),
            name => 'B',
            sort_name => 'B',
            type => undef,
        },
    ]);

    my $tags = $c->sql->select_list_of_hashes('SELECT * FROM tag ORDER BY id');

    cmp_deeply($tags, [
        {
            id => 1,
            name => $long_unicode_tag1,
            ref_count => 1,
        },
        {
            id => 2,
            name => $long_unicode_tag2,
            ref_count => 1,
        },
    ]);

    my $editors = $c->sql->select_list_of_hashes('SELECT * FROM editor ORDER BY id');

    cmp_deeply($editors, [
        {
            area => undef,
            bio => undef,
            birth_date => undef,
            deleted => 0,
            email => '',
            email_confirm_date => '2013-07-26 11:48:31.088042+00',
            gender => undef,
            ha1 => '03503a81a03bdbb6055f4a6c8b86b5b8',
            id => 4,
            last_login_date => ignore(),
            last_updated => ignore(),
            member_since => ignore(),
            name => 'ModBot',
            password => '{CLEARTEXT}mb',
            privs => 0,
            website => undef,
        },
        {
            area => undef,
            bio => undef,
            birth_date => undef,
            deleted => 0,
            email => '',
            email_confirm_date => '2020-11-26 01:13:57.82052+00',
            gender => undef,
            ha1 => '62918b6c0e34b4bf056ecad67c96b765',
            id => 5,
            last_login_date => ignore(),
            last_updated => '2020-11-26 01:13:41.810622+00',
            member_since => '2020-11-26 01:13:41.810622+00',
            name => 'false_editor',
            password => '{CLEARTEXT}mb',
            privs => 0,
            website => undef,
        },
    ]);

    $exec_sql->(<<~'EOSQL');
        SET client_min_messages TO WARNING;
        TRUNCATE artist CASCADE;
        TRUNCATE artist_tag CASCADE;
        TRUNCATE tag CASCADE;
        EOSQL
};

run_me;
done_testing;
