use strict;
use warnings;

use English;
use File::Spec;
use File::Temp qw( tempdir );
use lib 't/lib';
use String::ShellQuote;
use Test::More;
use Test::Routine;
use Test::Routine::Util;
use Test::Deep qw( cmp_deeply ignore );
use MusicBrainz::Server::Test;
use utf8;

use DBDefs;
use MusicBrainz::Server::Context;
use aliased 't::script::ReplicationTest';
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

test all => sub {
    my $root = DBDefs->MB_SERVER_ROOT;
    my $output_dir = tempdir('t-fullexport-XXXXXXXX', DIR => '/tmp', CLEANUP => 1);
    my $test = ReplicationTest->new(output_dir => $output_dir);
    my $master_c = $test->master_c;
    my $mirror_c = $test->mirror_c;

    # MBS-9342
    my $long_unicode_tag1 = '松' x 255;
    my $long_unicode_tag2 = '変' x 255;

    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~"SQL");
        BEGIN;
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
        SQL

    $test->export_all_tables(
        '--with-full-export',
        '--with-replication',
    );

    my $quoted_output_dir = shell_quote($output_dir);
    system("cd $quoted_output_dir && md5sum -c MD5SUMS") == 0
        or die $OS_ERROR;
    system("cd $quoted_output_dir && sha256sum -c SHA256SUMS") == 0
        or die $OS_ERROR;

    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~"SQL");
        SET client_min_messages TO WARNING;
        BEGIN;
        INSERT INTO artist (id, gid, name, sort_name, last_updated)
            VALUES (667, 'b3d9590e-cd28-47a9-838a-ed41a78002f5', 'B', 'B', '2016-05-03 20:00:00+00');
        UPDATE artist SET name = 'Updated A' WHERE id = 666;
        INSERT INTO tag (id, name, ref_count)
            VALUES (2, '$long_unicode_tag2', 1);
        INSERT INTO artist_tag (artist, tag, count, last_updated)
            VALUES (667, 2, 1, '2016-05-03 20:00:00+00');
        INSERT INTO editor (id, name, password, ha1)
            VALUES (909, 'ZZZ', '{CLEARTEXT}mb', '');
        COMMIT;
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    system(
        File::Spec->catfile($root, 'admin/MBImport.pl'),
        '--database', 'TEST_MIRROR',
        '--delete-first',
        File::Spec->catfile($output_dir, 'mbdump.tar.bz2'),
        File::Spec->catfile($output_dir, 'mbdump-derived.tar.bz2'),
        File::Spec->catfile($output_dir, 'mbdump-editor.tar.bz2'),
        File::Spec->catfile($output_dir, 'mbdump-cover-art-archive.tar.bz2'),
        File::Spec->catfile($output_dir, 'mbdump-event-art-archive.tar.bz2'),
    );

    system (
        File::Spec->catfile($root, 'admin/replication/LoadReplicationChanges'),
        '--base-uri', 'file://' . $output_dir,
        '--database', 'TEST_MIRROR',
        '--lockfile', '/tmp/.mb-LoadReplicationChanges-TEST_MIRROR',
        '--nodbmirror2',
    );

    my $artists = $mirror_c->sql->select_list_of_hashes('SELECT * FROM artist ORDER BY id');

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

    my $tags = $mirror_c->sql->select_list_of_hashes('SELECT * FROM tag ORDER BY id');

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

    my $editors = $mirror_c->sql->select_list_of_hashes('SELECT * FROM editor ORDER BY id');

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

    # MBS-12400: Check that non-musicbrainz-schema tables have been dumped
    # and imported. One effect of failing to schema-qualify the dumped
    # tables' file names might be tables like event_art_archive.art_type and
    # cover_art_archive.art_type clobbering each other.

    my $cover_art_types = $mirror_c->sql->select_list_of_hashes('SELECT * FROM cover_art_archive.art_type WHERE id = 1');

    cmp_deeply($cover_art_types, [
        {
            id => 1,
            name => 'Front',
            parent => undef,
            child_order => 0,
            description => undef,
            gid => 'ac337166-a2b3-340c-a0b4-e2b00f1d40a2',
        },
    ]);

    my $event_art_types = $mirror_c->sql->select_list_of_hashes('SELECT * FROM event_art_archive.art_type WHERE id = 1');

    cmp_deeply($event_art_types, [
        {
            id => 1,
            name => 'Poster',
            parent => undef,
            child_order => 0,
            description => undef,
            gid => '7ced53fc-bb27-33ae-aeef-79d6e24fec3c',
        },
    ]);
};

run_me;
done_testing;

1;
