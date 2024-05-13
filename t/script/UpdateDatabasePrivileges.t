use strict;
use warnings;

use Test::Fatal;
use Test::More;
use Test::Routine;
use Test::Routine::Util;

use DBDefs;
use MusicBrainz::Server::Context;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

$ENV{MUSICBRAINZ_RUNNING_TESTS} = 1;

test all => sub {
    my $c = MusicBrainz::Server::Context->create_script_context(
        database => 'SYSTEM_TEST',
    );

    $c->sql->auto_commit;
    $c->sql->do(<<~'SQL');
        CREATE ROLE db_priv_test_musicbrainz_ro WITH LOGIN;
        CREATE ROLE db_priv_test_caa_redirect WITH LOGIN;
        CREATE ROLE db_priv_test_sir WITH LOGIN;
        CREATE TABLE musicbrainz.db_priv_test ( val INTEGER );
        SQL

    my $test_db = Databases->get('SYSTEM_TEST');
    my @roles = qw( musicbrainz_ro caa_redirect sir );

    Databases->register_databases(
        map {
            ("db_priv_test_${_}" => {
                database    => $test_db->database,
                host        => $test_db->host,
                password    => $test_db->password,
                port        => $test_db->port,
                username    => "db_priv_test_${_}",
            })
        } @roles,
    );

    for my $role (@roles) {
        my $conn = Databases->get_connection("db_priv_test_${role}");
        my $sql = Sql->new($conn->conn);

        $sql->auto_commit;
        like exception {
            $sql->do('SELECT * FROM musicbrainz.db_priv_test;');
        }, qr/permission denied for schema musicbrainz/,
            "$role cannot SELECT from musicbrainz.db_priv_test before running script";

        $sql->auto_commit;
        like exception {
            $sql->do('INSERT INTO musicbrainz.db_priv_test VALUES (1);');
        }, qr/permission denied for schema musicbrainz/,
            "$role cannot INSERT INTO musicbrainz.db_priv_test before running script";
    }

    system(
        File::Spec->catfile(
            DBDefs->MB_SERVER_ROOT,
            'admin/UpdateDatabasePrivileges.pl',
        ),
        '--database', 'SYSTEM_TEST',
        '--primary-ro-role', 'db_priv_test_musicbrainz_ro',
        '--other-ro-role', 'db_priv_test_caa_redirect',
        '--other-ro-role', 'db_priv_test_sir',
    );

    for my $role (@roles) {
        my $conn = Databases->get_connection("db_priv_test_${role}");
        my $sql = Sql->new($conn->conn);

        $sql->auto_commit;
        ok !exception {
            $sql->do('SELECT * FROM musicbrainz.db_priv_test;');
        }, "$role can SELECT from musicbrainz.db_priv_test after running script";

        $sql->auto_commit;
        like exception {
            $sql->do('INSERT INTO musicbrainz.db_priv_test VALUES (1);');
        }, qr/permission denied for table db_priv_test/,
            "$role can INSERT into musicbrainz.db_priv_test after running script";
    }

    system(
        File::Spec->catfile(
            DBDefs->MB_SERVER_ROOT,
            'admin/UpdateDatabasePrivileges.pl',
        ),
        '--database', 'SYSTEM_TEST',
        '--primary-ro-role', 'db_priv_test_musicbrainz_ro',
        '--other-ro-role', 'db_priv_test_caa_redirect',
        '--other-ro-role', 'db_priv_test_sir',
        '--nogrant',
    );

    $c->sql->auto_commit;
    $c->sql->do(<<~'SQL');
        DROP ROLE IF EXISTS db_priv_test_musicbrainz_ro;
        DROP ROLE IF EXISTS db_priv_test_caa_redirect;
        DROP ROLE IF EXISTS db_priv_test_sir;
        DROP TABLE IF EXISTS musicbrainz.db_priv_test;
        SQL
};

run_me;
done_testing;

1;
