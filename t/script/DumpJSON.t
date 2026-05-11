use strict;
use warnings;

use English;
use File::Slurp;
use File::Spec;
use File::Temp;
use JSON;
use lib 't/lib';
use String::ShellQuote;
use Test::Deep qw( cmp_bag );
use Test::More;
use Test::Routine;
use Test::Routine::Util;

use DBDefs;
use MusicBrainz::Server::Context;
use aliased 't::script::ReplicationTest';

$ENV{MUSICBRAINZ_RUNNING_TESTS} = 1;

our @dumped_entity_types = qw(
    area
    artist
    event
    instrument
    label
    place
    recording
    release
    release-group
    series
    work
);

test all => sub {
    my $root = DBDefs->MB_SERVER_ROOT;
    my $test = ReplicationTest->new;
    my $master_c = $test->master_c;
    my $mirror_c = $test->mirror_c;

    my $foreign_keys_dump = File::Spec->catfile(
        $test->output_dir,
        'foreign_keys',
    );

    system (
        File::Spec->catfile($root, 'script/dump_foreign_keys.pl'),
        '--database' => 'TEST_MASTER',
        '--output' => $foreign_keys_dump,
    );

    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
             VALUES (3, '30238ead-59fa-41e2-a7ab-b7f6e6363c4b', 'Blue Guy', 'Blues Guy');
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );
    $test->load_replication_changes;

    my $output_dir;
    my $new_output_dir = sub {
        $output_dir = File::Temp->newdir(
            't-json-dump-XXXXXXX', DIR => '/tmp', CLEANUP => 1);
    };

    my $build_full_dump = sub {
        $new_output_dir->();
        system (
            File::Spec->catfile($root, 'admin/DumpJSON'),
            '--database' => 'TEST_MIRROR',
            '--compress',
            '--output-dir' => $output_dir,
        );
        my $full_json_dump_replication_sequence = $mirror_c->sql->select_single_value(
            'SELECT full_json_dump_replication_sequence ' .
            'FROM json_dump.control',
        );
        for my $type (@dumped_entity_types) {
            $type =~ s/-/_/g;
            my $unneeded_row_count = $mirror_c->sql->select_single_value(qq{
                SELECT count(*) FROM json_dump.${type}_json a
                 WHERE a.replication_sequence < $full_json_dump_replication_sequence
                   AND EXISTS (SELECT 1 FROM json_dump.${type}_json b
                                WHERE b.id = a.id AND b.replication_sequence >= $full_json_dump_replication_sequence);
            });
            is($unneeded_row_count, 0);
        }
    };

    my $build_incremental_dump = sub {
        $new_output_dir->();
        system (
            File::Spec->catfile($root, 'admin/DumpIncrementalJSON'),
            '--database' => 'TEST_MIRROR',
            '--compress',
            '--output-dir' => $output_dir,
            '--replication-access-uri' => 'file://' .
                $test->output_dir,
            '--foreign-keys-dump' => $foreign_keys_dump,
        );
    };

    my $json = JSON->new->canonical->utf8;
    my $test_dump = sub {
        my ($dir, $entity, $expected) = @_;

        my $quoted_dir = shell_quote($dir);
        system("cd $quoted_dir && md5sum -c MD5SUMS") == 0 or die $OS_ERROR;
        system("cd $quoted_dir && sha256sum -c SHA256SUMS") == 0 or die $OS_ERROR;

        my $entity_dir = File::Spec->catdir($dir, $entity);
        my $quoted_entity_dir = shell_quote($entity_dir);

        system 'mkdir', '-p', $quoted_entity_dir;
        system(
            'tar',
            '-C', $quoted_entity_dir,
            '-xJf', shell_quote(File::Spec->catfile($dir, "$entity.tar.xz")),
        ) == 0 or die $OS_ERROR;

        my $got = read_file(
            File::Spec->catfile($entity_dir, 'mbdump', $entity));
        $got = [map { $json->decode($_) } split /\n/, $got];
        cmp_bag($got, $expected);

        $got = read_file(
            File::Spec->catfile($dir, $entity, 'JSON_DUMPS_SCHEMA_NUMBER'));
        chomp $got;
        is($got, '1');
    };

    my $test_dumps_empty_except = sub {
        my $dir = shift;
        my %except = map { $_ => 1 } @_;

        for (@dumped_entity_types) {
            next if $except{$_};
            ok(! -e File::Spec->catdir($dir, $_));
        }
    };

    $build_full_dump->();

    my %artist1 = (
        aliases => [],
        annotation => undef,
        area => undef,
        'begin-area' => undef,
        country => undef,
        disambiguation => '',
        'end-area' => undef,
        gender => undef,
        'gender-id' => undef,
        genres => [],
        id => '30238ead-59fa-41e2-a7ab-b7f6e6363c4b',
        ipis => [],
        isnis => [],
        'life-span' => {
            begin => undef,
            end => undef,
            ended => JSON::false,
        },
        name => 'Blue Guy',
        rating => {
            value => undef,
            'votes-count' => 0,
        },
        relations => [],
        'sort-name' => 'Blues Guy',
        tags => [],
        type => undef,
        'type-id' => undef,
    );

    $test_dump->($output_dir, 'artist', [
        \%artist1,
    ]);
    $test_dumps_empty_except->($output_dir, 'artist');

    # Fix the name.
    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        UPDATE artist SET name = 'Blues Guy' WHERE id = 3;
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    $build_incremental_dump->();

    $artist1{name} = 'Blues Guy';
    $test_dump->("$output_dir/json-dump-3", 'artist', [
        \%artist1,
    ]);
    $test_dumps_empty_except->($output_dir, 'artist');

    # Insert some works, and make sure they're picked up as changes.
    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        INSERT INTO work (id, name, gid)
             VALUES (1, 'A', 'daf4327f-19a0-450b-9448-e0ea1c707136'),
                    (2, 'B', 'b6c76104-d64c-4883-b395-c74f782b751c'),
                    (3, 'C', '79e0f9b8-db97-4bfb-9995-217478dd6c3e');
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    $build_incremental_dump->();

    my %work_common = (
        aliases => [],
        annotation => undef,
        attributes => [],
        disambiguation => '',
        genres => [],
        iswcs => [],
        language => undef,
        languages => [],
        rating => {
            value => undef,
            'votes-count' => 0,
        },
        relations => [],
        tags => [],
        type => undef,
        'type-id' => undef,
    );
    my %work1 = (%work_common, title => 'A', id => 'daf4327f-19a0-450b-9448-e0ea1c707136');
    my %work2 = (%work_common, title => 'B', id => 'b6c76104-d64c-4883-b395-c74f782b751c');
    my %work3 = (%work_common, title => 'C', id => '79e0f9b8-db97-4bfb-9995-217478dd6c3e');

    $test_dump->("$output_dir/json-dump-4", 'work', [
        \%work1,
        \%work2,
        \%work3,
    ]);
    $test_dumps_empty_except->($output_dir, 'work');

    # Insert an ISWC for the first work, a composer relationship for the
    # second, and change the name of the third.
    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        INSERT INTO iswc (id, work, iswc) VALUES (1, 1, 'T-100.000.000-1');
        INSERT INTO link (id, link_type, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, attribute_count, ended)
             VALUES (1, 168, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'f');
        INSERT INTO l_artist_work (id, link, entity0, entity1, link_order, entity0_credit, entity1_credit)
             VALUES (1, 1, 3, 2, 0, '', '');
        UPDATE work SET name = 'C?' WHERE id = 3;
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    $build_incremental_dump->();

    $artist1{relations} = [
        {
            'attribute-ids' => {},
            'attribute-values' => {},
            attributes => [],
            begin => undef,
            direction => 'forward',
            end => undef,
            ended => JSON::false,
            'source-credit' => '',
            'target-credit' => '',
            'target-type' => 'work',
            type => 'composer',
            'type-id' => 'd59d99ea-23d4-4a80-b066-edca32ee158f',
            work => {
                attributes => [],
                disambiguation => '',
                id => 'b6c76104-d64c-4883-b395-c74f782b751c',
                iswcs => [],
                language => undef,
                languages => [],
                title => 'B',
                type => undef,
                'type-id' => undef,
            },
        },
    ];

    $test_dump->("$output_dir/json-dump-5", 'artist', [
        \%artist1,
    ]);

    $work1{iswcs} = ['T-100.000.000-1'];
    $work2{relations} = [
        {
            artist => {
                disambiguation => '',
                id => '30238ead-59fa-41e2-a7ab-b7f6e6363c4b',
                name => 'Blues Guy',
                'sort-name' => 'Blues Guy',
                type => undef,
                'type-id' => undef,
                country => JSON::null,
            },
            'attribute-ids' => {},
            'attribute-values' => {},
            attributes => [],
            begin => undef,
            direction => 'backward',
            end => undef,
            ended => JSON::false,
            'source-credit' => '',
            'target-credit' => '',
            'target-type' => 'artist',
            type => 'composer',
            'type-id' => 'd59d99ea-23d4-4a80-b066-edca32ee158f',
        },
    ];
    $work3{title} = 'C?';

    $test_dump->("$output_dir/json-dump-5", 'work', [
        \%work1,
        \%work2,
        \%work3,
    ]);
    $test_dumps_empty_except->($output_dir, 'artist', 'work');

    # Insert a release.
    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        INSERT INTO artist_credit (id, gid, name, artist_count)
             VALUES (1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7', 'Blues Guy', 1);
        INSERT INTO artist_credit_name (artist_credit, position, artist, name)
             VALUES (1, 0, 3, 'Blues Guy');
        -- insert standalone recording (with associated EDIT_RECORDING_CREATE edit)
        INSERT INTO editor (id, name, password, email, email_confirm_date, ha1)
             VALUES (1, 'new_editor', '{CLEARTEXT}password', 'example@example.com', '2005-10-20', 'e1dd8fee8ee728b0ddc8027d3a3db478');
        INSERT INTO edit (id, editor, type, status, autoedit, open_time, close_time, expire_time, language, quality)
             VALUES (1, 1, 71, 2, 0, now(), now(), now(), NULL, 1);
        INSERT INTO edit_data (edit, data) VALUES (1, '{}');
        INSERT INTO recording (id, gid, name, artist_credit, length)
            VALUES (1, '4293ab04-ec12-4c5e-9ffa-98ee6e833bb3', 'The Blues', 1, 238000);
        INSERT INTO edit_recording (edit, recording) VALUES (1, 1);
        INSERT INTO release_group (id, gid, name, artist_credit, type)
             VALUES (1, 'e0e39108-5a94-4736-83bb-09c1682a2ab5', 'Blue Hits', 1, NULL);
        INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode)
             VALUES (1, '8ddb6392-a3d2-4c62-8a3f-9289dfc627b0', 'Blue Hits', 1, 1, 1, NULL, NULL, NULL, NULL);
        INSERT INTO medium (id, gid, release, position, format, name)
             VALUES (1, '88499c4a-8570-4430-908f-4a661b1d8e64', 1, 1, 1, '');
        INSERT INTO track (id, gid, recording, medium, position, number, name, artist_credit, length)
             VALUES (1, 'a5e1dc36-b61e-4dba-86fa-ec11b4f18d20', 1, 1, 1, '1', 'The Blues', 1, NULL);
        SQL

    my $make_artist_credit = sub {
        my ($name, %extra) = @_;
        return [{
            artist => {
                disambiguation => '',
                id => '30238ead-59fa-41e2-a7ab-b7f6e6363c4b',
                name => 'Blues Guy',
                'sort-name' => 'Blues Guy',
                type => undef,
                'type-id' => undef,
                country => JSON::null,
                %extra,
            },
            joinphrase => '',
            name => $name || 'Blues Guy',
        }];
    };

    my $artist_credit1 = $make_artist_credit->('');

    my %release1 = (
        aliases => [],
        annotation => undef,
        'artist-credit' => $make_artist_credit->('', aliases => [], tags => [], genres => []),
        asin => undef,
        barcode => undef,
        'cover-art-archive' => {
            artwork => JSON::false,
            back => JSON::false,
            count => 0,
            darkened => JSON::false,
            front => JSON::false,
        },
        disambiguation => '',
        genres => [],
        id => '8ddb6392-a3d2-4c62-8a3f-9289dfc627b0',
        'label-info' => [],
        media => [
            {
                discs => [],
                format => 'CD',
                'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                id => '88499c4a-8570-4430-908f-4a661b1d8e64',
                position => 1,
                title => '',
                'track-count' => 1,
                'track-offset' => 0,
                tracks => [
                    {
                        'artist-credit' => $make_artist_credit->('', aliases => []),
                        id => 'a5e1dc36-b61e-4dba-86fa-ec11b4f18d20',
                        length => undef,
                        number => '1',
                        position => 1,
                        recording => {
                            aliases => [],
                            'artist-credit' => $artist_credit1,
                            disambiguation => '',
                            genres => [],
                            id => '4293ab04-ec12-4c5e-9ffa-98ee6e833bb3',
                            isrcs => [],
                            length => undef,
                            relations => [],
                            tags => [],
                            title => 'The Blues',
                            video => JSON::false,
                        },
                        title => 'The Blues',
                    },
                ],
            },
        ],
        packaging => undef,
        'packaging-id' => undef,
        quality => 'normal',
        relations => [],
        'release-group' => {
            aliases => [],
            'artist-credit' => $make_artist_credit->('', aliases => []),
            disambiguation => '',
            'first-release-date' => '',
            genres => [],
            id => 'e0e39108-5a94-4736-83bb-09c1682a2ab5',
            'primary-type' => undef,
            'primary-type-id' => undef,
            'secondary-type-ids' => [],
            'secondary-types' => [],
            tags => [],
            title => 'Blue Hits',
        },
        status => 'Official',
        'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
        tags => [],
        'text-representation' => {
            language => undef,
            script => undef,
        },
        title => 'Blue Hits',
    );

    my %release_group1 = (
        aliases => [],
        annotation => undef,
        'artist-credit' => $make_artist_credit->('', aliases => [], tags => [], genres => []),
        disambiguation => '',
        'first-release-date' => '',
        genres => [],
        id => 'e0e39108-5a94-4736-83bb-09c1682a2ab5',
        'primary-type' => undef,
        'primary-type-id' => undef,
        rating => {
            value => undef,
            'votes-count' => 0,
        },
        relations => [],
        'secondary-type-ids' => [],
        'secondary-types' => [],
        tags => [],
        title => 'Blue Hits',
    );

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    $build_incremental_dump->();

    $test_dump->("$output_dir/json-dump-6", 'release', [
        \%release1,
    ]);
    $test_dump->("$output_dir/json-dump-6", 'release-group', [
        \%release_group1,
    ]);
    $test_dumps_empty_except->($output_dir, 'release', 'release-group');

    # Update the track artist credit.
    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        INSERT INTO artist_credit (id, gid, name, artist_count)
             VALUES (2, 'c44109ce-57d7-3691-84c8-37926e3d41d2', 'B.G.', 1);
        INSERT INTO artist_credit_name (artist_credit, position, artist, name)
             VALUES (2, 0, 3, 'B.G.');
        UPDATE track SET artist_credit = 2 WHERE id = 1;
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    $build_incremental_dump->();

    my $artist_credit2_toplevel = $make_artist_credit->('B.G.', aliases => []);
    $release1{media}[0]{tracks}[0]{'artist-credit'} = $artist_credit2_toplevel;

    $test_dump->("$output_dir/json-dump-7", 'release', [
        \%release1,
    ]);
    $test_dumps_empty_except->($output_dir, 'release');

    # Build another full dump.
    $build_full_dump->();

    $test_dump->($output_dir, 'artist', [
        \%artist1,
    ]);
    $test_dump->($output_dir, 'release', [
        \%release1,
    ]);
    $test_dump->($output_dir, 'release-group', [
        \%release_group1,
    ]);
    $test_dump->($output_dir, 'work', [
        \%work1,
        \%work2,
        \%work3,
    ]);
    $test_dumps_empty_except->($output_dir, qw( artist release release-group work ));

    # Delete the release.
    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        DELETE FROM track WHERE id = 1;
        DELETE FROM medium WHERE id = 1;
        DELETE FROM release WHERE id = 1;
        -- Recording length is unset once the track is deleted. Re-add it.
        UPDATE recording SET length = 238000 WHERE id = 1;
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    $build_incremental_dump->();

    # No incremental dumps should have been generated.
    $test_dumps_empty_except->($output_dir);

    # Build another full dump. The now-standalone recording should appear in
    # the recording dump.
    $build_full_dump->();

    $test_dump->($output_dir, 'recording', [
        {
            aliases => [],
            annotation => undef,
            'artist-credit' => $make_artist_credit->('', aliases => [], tags => [], genres => []),
            disambiguation => '',
            genres => [],
            id => '4293ab04-ec12-4c5e-9ffa-98ee6e833bb3',
            length => 238000,
            rating => {
                value => undef,
                'votes-count' => 0,
            },
            relations => [],
            tags => [],
            title => 'The Blues',
            video => JSON::false,
            isrcs => [],
        },
    ]);
    $test_dumps_empty_except->($output_dir, qw( artist recording release-group work ));
};

run_me;
done_testing;

1;
