use DBDefs;
use File::Slurp;
use File::Spec;
use File::Temp;
use JSON;
use List::UtilsBy qw( sort_by );
use String::ShellQuote;
use Test::Deep qw( cmp_bag );
use Test::More;
use Test::Routine;
use Test::Routine::Util;
use MusicBrainz::Server::Context;

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
    my $schema_seq = DBDefs->DB_SCHEMA_SEQUENCE;
    my $psql = File::Spec->catfile($root, 'admin/psql');

    my $exec_sql = sub {
        my $sql = shell_quote(shift);

        system 'sh', '-c' => "echo $sql | $psql TEST_JSON_DUMP";
    };

    $exec_sql->(<<~"SQL");
        INSERT INTO replication_control (current_schema_sequence, current_replication_sequence, last_replication_date)
            VALUES ($schema_seq, 1, now() - interval '1 hour');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '30238ead-59fa-41e2-a7ab-b7f6e6363c4b', 'Blue Guy', 'Blues Guy');
        SQL

    my $output_dir;
    my $new_output_dir = sub {
        $output_dir = File::Temp->newdir(
            't-json-dump-XXXXXXX', DIR => '/tmp', CLEANUP => 1);
    };

    my $rep_dir;
    my $new_replication_dir = sub {
        $rep_dir = File::Temp->newdir(
            't-json-dump-packets-XXXXXXX', DIR => '/tmp', CLEANUP => 1);
    };

    my $c = MusicBrainz::Server::Context->create_script_context(
        database => 'TEST_JSON_DUMP',
    );

    my $build_full_dump = sub {
        $new_output_dir->();
        system (
            File::Spec->catfile($root, 'admin/DumpJSON'),
            '--database' => 'TEST_JSON_DUMP',
            '--compress',
            '--output-dir' => $output_dir,
        );
        my $full_json_dump_replication_sequence = $c->sql->select_single_value(
            'SELECT full_json_dump_replication_sequence ' .
            'FROM json_dump.control',
        );
        for my $type (@dumped_entity_types) {
            $type =~ s/-/_/g;
            my $unneeded_row_count = $c->sql->select_single_value(qq{
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
            '--database' => 'TEST_JSON_DUMP',
            '--compress',
            '--output-dir' => $output_dir,
            '--replication-access-uri' => "file://$rep_dir",
        );
    };

    my $json = JSON->new->canonical->utf8;
    my $test_dump = sub {
        my ($dir, $entity, $expected) = @_;

        my $quoted_dir = shell_quote($dir);
        system("cd $quoted_dir && md5sum -c MD5SUMS") == 0 or die $!;
        system("cd $quoted_dir && sha256sum -c SHA256SUMS") == 0 or die $!;

        my $entity_dir = File::Spec->catdir($dir, $entity);
        my $quoted_entity_dir = shell_quote($entity_dir);

        system 'mkdir', '-p', $quoted_entity_dir;
        system(
            'tar',
            '-C', $quoted_entity_dir,
            '-xJf', shell_quote(File::Spec->catfile($dir, "$entity.tar.xz")),
        ) == 0 or die $!;

        chomp $expected;
        my $got = read_file(
            File::Spec->catfile($entity_dir, 'mbdump', $entity));
        $got = [map { $json->decode($_) } split "\n", $got];
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

    my $build_packet = sub {
        my ($number, $pending, $pendingdata) = @_;

        $new_replication_dir->();

        $pending = shell_quote($pending);
        $pendingdata = shell_quote($pendingdata);
        my $replication_info = shell_quote(qq({"last_packet": "replication-$number.tar.bz2"}));

        system "echo $replication_info > $rep_dir/replication-info";
        system "mkdir -p $rep_dir/mbdump";
        system "echo $pending > $rep_dir/mbdump/dbmirror_pending";
        system "echo $pendingdata > $rep_dir/mbdump/dbmirror_pendingdata";
        system "echo $schema_seq > $rep_dir/SCHEMA_SEQUENCE";
        system "echo $number > $rep_dir/REPLICATION_SEQUENCE";
        system "tar -C $rep_dir -cf - mbdump SCHEMA_SEQUENCE REPLICATION_SEQUENCE | " .
               "bzip2 > $rep_dir/replication-$number.tar.bz2";
    };

    $build_full_dump->();

    my %artist1 = (
        aliases => [],
        annotation => undef,
        area => undef,
        'begin-area' => undef,
        begin_area => undef,
        country => undef,
        disambiguation => '',
        'end-area' => undef,
        end_area => undef,
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
    chomp (my $dbmirror_pending = <<"EOF");
1\t"musicbrainz"."artist"\tu\t1
2\t"musicbrainz"."replication_control"\tu\t2
EOF

    # Lines must have a trailing space.
    chomp (my $dbmirror_pendingdata = <<"EOF");
1\tt\t"id"='1'\x{20}
1\tf\t"id"='1' "name"='Blues Guy' "last_updated"='2015-10-03 20:03:56.069908+00'\x{20}
2\tt\t"id"='1'\x{20}
2\tf\t"id"='1' "current_replication_sequence"='2'\x{20}
EOF

    $build_packet->(2, $dbmirror_pending, $dbmirror_pendingdata);

    $build_incremental_dump->();

    $artist1{name} = 'Blues Guy';
    $test_dump->("$output_dir/json-dump-2", 'artist', [
        \%artist1,
    ]);
    $test_dumps_empty_except->($output_dir, 'artist');

    # Insert some works, and make sure they're picked up as changes.
    chomp ($dbmirror_pending = <<"EOF");
1\t"musicbrainz"."work"\ti\t1
2\t"musicbrainz"."work"\ti\t1
3\t"musicbrainz"."work"\ti\t1
4\t"musicbrainz"."replication_control"\tu\t2
EOF

    chomp ($dbmirror_pendingdata = <<"EOF");
1\tf\t"id"='1' "name"='A' "gid"='daf4327f-19a0-450b-9448-e0ea1c707136' "last_updated"='2015-10-04 02:03:04.070000+00'\x{20}
2\tf\t"id"='2' "name"='B' "gid"='b6c76104-d64c-4883-b395-c74f782b751c' "last_updated"='2015-10-04 01:02:03.060000+00'\x{20}
3\tf\t"id"='3' "name"='C' "gid"='79e0f9b8-db97-4bfb-9995-217478dd6c3e' "last_updated"='2015-10-04 00:01:02.050000+00'\x{20}
4\tt\t"id"='1'\x{20}
4\tf\t"id"='1' "current_replication_sequence"='3'\x{20}
EOF

    $build_packet->(3, $dbmirror_pending, $dbmirror_pendingdata);

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

    $test_dump->("$output_dir/json-dump-3", 'work', [
        \%work1,
        \%work2,
        \%work3,
    ]);
    $test_dumps_empty_except->($output_dir, 'work');

    # Insert an ISWC for the first work, a composer relationship for the
    # second, and change the name of the third.
    $dbmirror_pending = '';
    chomp ($dbmirror_pending = <<"EOF");
1\t"musicbrainz"."iswc"\ti\t1
2\t"musicbrainz"."link"\ti\t2
3\t"musicbrainz"."l_artist_work"\ti\t2
4\t"musicbrainz"."work"\tu\t3
5\t"musicbrainz"."replication_control"\tu\t4
EOF

    chomp ($dbmirror_pendingdata = <<"EOF");
1\tf\t"id"='1' "work"='1' "iswc"='T-100.000.000-1' "created"='2015-10-05 06:54:32.101234-05'\x{20}
2\tf\t"id"='1' "id"='1' "link_type"='168' "begin_date_year"= "begin_date_month"= "begin_date_day"= "end_date_year"= "end_date_month"= "end_date_day"= "attribute_count"='0' "created"='2017-04-05 01:07:52.449236+00' "ended"='f'\x{20}
3\tf\t"id"='1' "id"='1' "link"='1' "entity0"='1' "entity1"='2' "edits_pending"='0' "last_updated"='2017-04-05 00:59:46.503449+00' "link_order"='0' "entity0_credit"='' "entity1_credit"=''\x{20}
4\tt\t"id"='3' "type"=\x{20}
4\tf\t"id"='3' "gid"='79e0f9b8-db97-4bfb-9995-217478dd6c3e' "name"='C?' "type"= "comment"='' "edits_pending"='0' "last_updated"='2017-04-05 01:12:36.172561+00'\x{20}
5\tt\t"id"='1'\x{20}
5\tf\t"id"='1' "current_replication_sequence"='4'\x{20}
EOF

    $build_packet->(4, $dbmirror_pending, $dbmirror_pendingdata);

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

    $test_dump->("$output_dir/json-dump-4", 'artist', [
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

    $test_dump->("$output_dir/json-dump-4", 'work', [
        \%work1,
        \%work2,
        \%work3,
    ]);
    $test_dumps_empty_except->($output_dir, 'artist', 'work');

    # Insert a release.
    chomp ($dbmirror_pending = <<"EOF");
1\t"musicbrainz"."artist_credit"\ti\t1
2\t"musicbrainz"."artist_credit_name"\ti\t1
3\t"musicbrainz"."recording"\ti\t1
4\t"musicbrainz"."release_group"\ti\t1
5\t"musicbrainz"."release"\ti\t1
6\t"musicbrainz"."medium"\ti\t1
7\t"musicbrainz"."track"\ti\t1
8\t"musicbrainz"."replication_control"\tu\t2
EOF

    chomp ($dbmirror_pendingdata = <<"EOF");
1\tf\t"id"='1' "name"='Blues Guy' "artist_count"='1' "ref_count"='1' "created"='2017-05-22 03:54:37.141481+00'\x{20}
2\tf\t"artist_credit"='1' "position"='0' "artist"='1' "name"='Blues Guy' "join_phrase"=''\x{20}
3\tf\t"id"='1' "gid"='4293ab04-ec12-4c5e-9ffa-98ee6e833bb3' "name"='The Blues' "artist_credit"='1' "length"='238000' "comment"='' "edits_pending"='0' "last_updated"='2017-05-22 03:54:37.141481+00' "video"='f'\x{20}
4\tf\t"id"='1' "gid"='e0e39108-5a94-4736-83bb-09c1682a2ab5' "name"='Blue Hits' "artist_credit"='1' "type"= "comment"='' "edits_pending"='0' "last_updated"='2017-05-22 03:54:37.141481+00'\x{20}
5\tf\t"id"='1' "gid"='8ddb6392-a3d2-4c62-8a3f-9289dfc627b0' "name"='Blue Hits' "artist_credit"='1' "release_group"='1' "status"='1' "packaging"= "language"= "script"= "barcode"= "comment"='' "edits_pending"='0' "quality"='-1' "last_updated"='2017-05-22 03:54:37.141481+00'\x{20}
6\tf\t"id"='1' "release"='1' "position"='1' "format"='1' "name"='' "edits_pending"='0' "last_updated"='2017-05-22 03:54:37.141481+00' "track_count"='0'\x{20}
7\tf\t"id"='1' "gid"='a5e1dc36-b61e-4dba-86fa-ec11b4f18d20' "recording"='1' "medium"='1' "position"='1' "number"='1' "name"='The Blues' "artist_credit"='1' "length"= "edits_pending"='0' "last_updated"='2017-05-22 03:54:37.141481+00' "is_data_track"='f'\x{20}
8\tt\t"id"='1'\x{20}
8\tf\t"id"='1' "current_replication_sequence"='5'\x{20}
EOF

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
            'votes-count' => 0
        },
        relations => [],
        'secondary-type-ids' => [],
        'secondary-types' => [],
        tags => [],
        title => 'Blue Hits'
    );

    $build_packet->(5, $dbmirror_pending, $dbmirror_pendingdata);

    $build_incremental_dump->();

    $test_dump->("$output_dir/json-dump-5", 'release', [
        \%release1,
    ]);
    $test_dump->("$output_dir/json-dump-5", 'release-group', [
        \%release_group1,
    ]);
    $test_dumps_empty_except->($output_dir, 'release', 'release-group');

    # Update the track artist credit.
    chomp ($dbmirror_pending = <<"EOF");
1\t"musicbrainz"."artist_credit"\ti\t1
2\t"musicbrainz"."artist_credit_name"\ti\t1
3\t"musicbrainz"."track"\tu\t1
4\t"musicbrainz"."replication_control"\tu\t2
EOF

    chomp ($dbmirror_pendingdata = <<"EOF");
1\tf\t"id"='2' "name"='B.G.' "artist_count"='1' "ref_count"='1' "created"='2017-05-22 04:41:37.645739+00'\x{20}
2\tf\t"artist_credit"='2' "position"='0' "artist"='1' "name"='B.G.' "join_phrase"=''\x{20}
3\tt\t"id"='1' "recording"='1' "medium"='1' "artist_credit"='1'\x{20}
3\tf\t"id"='1' "gid"='a5e1dc36-b61e-4dba-86fa-ec11b4f18d20' "recording"='1' "medium"='1' "position"='1' "number"='1' "name"='The Blues' "artist_credit"='2' "length"= "edits_pending"='0' "last_updated"='2017-05-22 04:41:37.645739+00' "is_data_track"='f'\x{20}
4\tt\t"id"='1'\x{20}
4\tf\t"id"='1' "current_replication_sequence"='6'\x{20}
EOF

    $build_packet->(6, $dbmirror_pending, $dbmirror_pendingdata);

    $build_incremental_dump->();

    my $artist_credit2_toplevel = $make_artist_credit->('B.G.', aliases => []);
    $release1{media}[0]{tracks}[0]{'artist-credit'} = $artist_credit2_toplevel;

    $test_dump->("$output_dir/json-dump-6", 'release', [
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
    chomp ($dbmirror_pending = <<"EOF");
1\t"musicbrainz"."track"\td\t1
2\t"musicbrainz"."medium"\td\t1
3\t"musicbrainz"."release"\td\t1
4\t"musicbrainz"."recording"\ti\t2
5\t"musicbrainz"."replication_control"\tu\t3
EOF

    chomp ($dbmirror_pendingdata = <<"EOF");
1\tt\t"id"='1'\x{20}
2\tt\t"id"='1'\x{20}
3\tt\t"id"='1'\x{20}
4\tf\t"id"='1' "gid"='4293ab04-ec12-4c5e-9ffa-98ee6e833bb3' "name"='The Blues' "artist_credit"='1' "length"='238000' "comment"='' "edits_pending"='0' "last_updated"='2017-05-22 03:54:37.141481+00' "video"='f'\x{20}
5\tt\t"id"='1'\x{20}
5\tf\t"id"='1' "current_replication_sequence"='7'\x{20}
EOF

    $build_packet->(7, $dbmirror_pending, $dbmirror_pendingdata);

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

    $exec_sql->(<<~'SQL');
        TRUNCATE artist CASCADE;
        TRUNCATE artist_credit CASCADE;
        TRUNCATE artist_credit_name CASCADE;
        TRUNCATE medium CASCADE;
        TRUNCATE recording CASCADE;
        TRUNCATE release CASCADE;
        TRUNCATE release_group CASCADE;
        TRUNCATE track CASCADE;
        TRUNCATE work CASCADE;
        TRUNCATE json_dump.control;
        TRUNCATE json_dump.tmp_checked_entities;
        SQL
};

run_me;
done_testing;
