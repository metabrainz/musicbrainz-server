use strict;
use warnings;

use DBDefs;
use File::Spec;
use String::ShellQuote;
use Test::More;
use Test::Routine;
use Test::Routine::Util;
use Test::Deep qw( cmp_deeply );
use MusicBrainz::Server::Test;
use utf8;

test all => sub {
    my $root = DBDefs->MB_SERVER_ROOT;
    my $psql = File::Spec->catfile($root, 'admin/psql');

    my $exec_sql = sub {
        my $sql = shell_quote(shift);

        system 'sh', '-c' => "echo $sql | $psql TEST";
    };

    $exec_sql->(<<~'SQL');
        BEGIN;

        INSERT INTO artist VALUES
            (1, '89ad4ac3-39f7-470e-963a-56509c546377', 'Various Artists', 'Various Artists', NULL, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, '', 0, '2020-03-25 13:00:27.07439+00', 'f', NULL, NULL),
            (163, '382f1005-e9ab-4684-afd4-0bdae4ee37f2', '2Pac', '2Pac', 1971, 6, 16, 1996, 9, 13, 1, NULL, 1, 'US rapper', 0, '2020-02-12 09:01:30.694647+00', 't', NULL, NULL),
            (535, '9e839dc3-55f3-4492-ad0e-a1a2e84275e2', 'Xzibit', 'Xzibit', 1974, 9, 18, NULL, NULL, NULL, 1, NULL, 1, '', 0, '2019-08-17 19:02:08.831976+00', 'f', NULL, NULL),
            (89559, '812d3015-2f4c-4fa7-bd7d-30ec4beb2c82', 'N.O.R.E.', 'N.O.R.E.', 1977, 9, 6, NULL, NULL, NULL, 1, NULL, 1, 'Noreaga, hip-hop artist from Queens, NY', 0, '2019-01-16 16:00:22.114503+00', 'f', NULL, NULL);

        INSERT INTO artist_credit VALUES
            (1, 'Various Artists', 1, 317291, '2011-05-16 16:32:11.963929+00', 0, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7'),
            (1033220, 'Various Artists', 1, 4215, '2012-08-12 01:20:35.977725+00', 0, '00c418d8-5284-3068-b6ea-58519bdadaa4'),
            (1091952, 'Various Artists', 1, 105, '2012-12-08 17:05:37.270366+00', 1, 'cf245a11-9fd0-307b-b476-c0955948b466'),
            (1079039, '2Pac feat. Xzibit & Noreaga', 3, 2, '2012-11-12 18:45:33.408347+00', 1, 'd9191f96-fa43-30f3-85a3-6b367b4da7c0'),
            (1216448, '2Pac feat. Xzibit & Noreaga', 3, 1, '2013-09-14 06:42:02.852405+00', 1, '30fac9ce-5a5e-32bc-8f25-ddd85896d73f'),
            (163, '2Pac', 1, 5626, '2011-05-16 16:32:11.963929+00', 1, 'a8e3f309-a7d2-3892-9dff-2efbbe5866a3');

        INSERT INTO artist_credit_name VALUES
            (1, 0, 1, 'Various Artists', ''),
            (1033220, 0, 1, 'Various Artists', ''),
            (1091952, 0, 1, 'Various Artists', ''),
            (1079039, 0, 163, '2Pac', ' feat. '),
            (1079039, 1, 535, 'Xzibit', ' & '),
            (1079039, 2, 89559, 'Noreaga', ''),
            (1216448, 0, 163, '2Pac', ' feat. '),
            (1216448, 1, 535, 'Xzibit', ' & '),
            (1216448, 2, 89559, 'Noreaga', ''),
            (163, 0, 163, '2Pac', '');

        INSERT INTO release_group VALUES
            (170162, 'f946cdb1-d74e-355d-a187-2a4a6200fbcc', 'Thug Nature', 163, 1, '', 0, '2012-05-15 19:01:58.718541+00'),
            (898532, 'f1cd9625-d7bb-41f4-9053-b9cf83068dcf', 'Atomic Beats', 1, 11, '', 0, '2009-12-03 03:11:59.75341+00'),
            (1292773, '76faec64-dbcc-4113-8c37-6b3f9674e383', '100 Hits of the Sixties', 1033220, 1, '', 0, '2020-03-22 13:20:03.259135+00'),
            (1219512, 'a4776762-078c-48d8-9f39-2fc68a702733', 'Chi: Harmony & Meditation - The Way to Your Soul', 1091952, NULL, '', 0, '2017-02-23 20:05:58.950458+00');

        INSERT INTO release VALUES
            (1328498, 'fb6a168b-e419-403c-a4a6-24fd992bbfb3', 'Thug Nature', 163, 170162, 3, NULL, 120, 28, NULL, '', 0, -1, '2015-10-29 17:01:28.262899+00');

        INSERT INTO medium VALUES
            (1372126, 1328498, 1, 1, '', 0, '2013-09-09 01:09:39.168562+00', 15);

        INSERT INTO recording VALUES
            (1723928, 'c490731a-35e2-466e-83c8-a1084f5adb21', 'Blood Money (remix)', 1079039, 237000, '', 0, '2015-09-03 01:00:44.001512+00', 'f');

        INSERT INTO track VALUES
            (15351681, '6d0598f0-a044-409f-a77a-97bbbb072b14', 1723928, 1372126, 12, 12, 'Blood Money (remix)', 1216448, 237000, 0, '2015-09-03 01:00:44.001512+00', 'f');

        COMMIT;
        SQL

    # Should skip all ACs with edits_pending != 0
    system (
        File::Spec->catfile($root, 'admin/cleanup/MergeDuplicateArtistCredits'),
        '--limit' => '10',
        '--database' => 'TEST',
    );

    my $c = MusicBrainz::Server::Context->create_script_context(database => 'TEST');

    my $rows = $c->sql->select_list_of_hashes(
        'SELECT id, name, artist_count FROM artist_credit ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1, name => 'Various Artists', artist_count => 1},
        {id => 163, name => '2Pac', artist_count => 1},
        {id => 1079039, name => '2Pac feat. Xzibit & Noreaga', artist_count => 3},
        {id => 1091952, name => 'Various Artists', artist_count => 1},
        {id => 1216448, name => '2Pac feat. Xzibit & Noreaga', artist_count => 3},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM release_group ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 170162, artist_credit => 163},
        {id => 898532, artist_credit => 1},
        {id => 1219512, artist_credit => 1091952},
        {id => 1292773, artist_credit => 1},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM release ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1328498, artist_credit => 163},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM recording ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1723928, artist_credit => 1079039},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM track ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 15351681, artist_credit => 1216448},
    ]);

    $c->sql->auto_commit(1);
    $c->sql->do('UPDATE artist_credit SET edits_pending = 0');

    system (
        File::Spec->catfile($root, 'admin/cleanup/MergeDuplicateArtistCredits'),
        '--limit' => '1',
        '--database' => 'TEST',
    );

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, name, artist_count FROM artist_credit ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1, name => 'Various Artists', artist_count => 1},
        {id => 163, name => '2Pac', artist_count => 1},
        {id => 1079039, name => '2Pac feat. Xzibit & Noreaga', artist_count => 3},
        {id => 1216448, name => '2Pac feat. Xzibit & Noreaga', artist_count => 3},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM release_group ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 170162, artist_credit => 163},
        {id => 898532, artist_credit => 1},
        {id => 1219512, artist_credit => 1},
        {id => 1292773, artist_credit => 1},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM release ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1328498, artist_credit => 163},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM recording ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1723928, artist_credit => 1079039},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM track ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 15351681, artist_credit => 1216448},
    ]);

    system (
        File::Spec->catfile($root, 'admin/cleanup/MergeDuplicateArtistCredits'),
        '--limit' => '10',
        '--database' => 'TEST',
    );

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, name, artist_count FROM artist_credit ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1, name => 'Various Artists', artist_count => 1},
        {id => 163, name => '2Pac', artist_count => 1},
        {id => 1079039, name => '2Pac feat. Xzibit & Noreaga', artist_count => 3},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM release_group ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 170162, artist_credit => 163},
        {id => 898532, artist_credit => 1},
        {id => 1219512, artist_credit => 1},
        {id => 1292773, artist_credit => 1},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM release ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1328498, artist_credit => 163},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM recording ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 1723928, artist_credit => 1079039},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT id, artist_credit FROM track ORDER BY id',
    );
    cmp_deeply($rows, [
        {id => 15351681, artist_credit => 1079039},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT gid, new_id FROM artist_credit_gid_redirect ORDER BY new_id, gid',
    );
    cmp_deeply($rows, [
        {gid => '00c418d8-5284-3068-b6ea-58519bdadaa4', new_id => 1},
        {gid => 'cf245a11-9fd0-307b-b476-c0955948b466', new_id => 1},
        {gid => '30fac9ce-5a5e-32bc-8f25-ddd85896d73f', new_id => 1079039},
    ]);

    $rows = $c->sql->select_list_of_hashes(
        'SELECT * FROM artist_credit_name ORDER BY artist_credit, position',
    );
    cmp_deeply($rows, [
        {
            artist_credit => 1,
            position => 0,
            artist => 1,
            name => 'Various Artists',
            join_phrase => '',
        },
        {
            artist_credit => 163,
            position => 0,
            artist => 163,
            name => '2Pac',
            join_phrase => '',
        },
        {
            artist_credit => 1079039,
            position => 0,
            artist => 163,
            name => '2Pac',
            join_phrase => ' feat. ',
        },
        {
            artist_credit => 1079039,
            position => 1,
            artist => 535,
            name => 'Xzibit',
            join_phrase => ' & ',
        },
        {
            artist_credit => 1079039,
            position => 2,
            artist => 89559,
            name => 'Noreaga',
            join_phrase => '',
        },
    ]);

    $exec_sql->(<<~'SQL');
        SET client_min_messages TO WARNING;
        TRUNCATE artist CASCADE;
        TRUNCATE artist_credit CASCADE;
        TRUNCATE artist_credit_name CASCADE;
        TRUNCATE release_group CASCADE;
        TRUNCATE release CASCADE;
        TRUNCATE medium CASCADE;
        TRUNCATE recording CASCADE;
        TRUNCATE track CASCADE;
        SQL
};

run_me;
done_testing;
