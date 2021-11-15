use DBDefs;
use File::Spec;
use File::Temp qw( tempdir );
use List::AllUtils qw( sort_by );
use String::ShellQuote;
use Test::Deep qw( cmp_deeply );
use Test::Routine;
use Test::Routine::Util;
use Test::More;
use WWW::Sitemap::XML;
use WWW::SitemapIndex::XML;

$ENV{MUSICBRAINZ_RUNNING_TESTS} = 1;

test 'Sitemap build scripts' => sub {
    # Because this test invokes external scripts that rely on certain test data
    # existing, it can't use t::Context or anything that would be contained
    # inside a transaction.

    my $root = DBDefs->MB_SERVER_ROOT;
    my $psql = File::Spec->catfile($root, 'admin/psql');

    my $exec_sql = sub {
        my $sql = shell_quote(shift);

        system 'sh', '-c' => "echo $sql | $psql TEST_SITEMAPS";
    };

    $exec_sql->(<<~'SQL');
        DO $$
        BEGIN
            EXECUTE 'ALTER DATABASE ' || current_database() ||
                ' SET TIMEZONE TO ''UTC''';
        END $$;

        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '30238ead-59fa-41e2-a7ab-b7f6e6363c4b', 'A', 'A');

        INSERT INTO artist_credit (id, name, artist_count)
            VALUES (1, 'A', 1);

        INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
            VALUES (1, 0, 1, 'A', '');
        SQL

    my $tmp = tempdir('t-sitemaps-XXXXXXXX', DIR => '/tmp', CLEANUP => 1);
    my $output_dir = File::Spec->catdir($tmp, 'sitemaps');
    system "mkdir -p $output_dir";

    my $build_overall = sub {
        my ($current_time) = @_;

        system (
            File::Spec->catfile($root, 'admin/BuildSitemaps.pl'),
            '--nocompress',
            '--database' => 'TEST_SITEMAPS',
            '--output-dir' => $output_dir,
            '--current-time' => $current_time,
        );
    };

    my $build_incremental = sub {
        my ($current_time) = @_;

        system (
            File::Spec->catfile($root, 'admin/BuildIncrementalSitemaps.pl'),
            '--nocompress',
            '--database' => 'TEST_SITEMAPS',
            '--output-dir' => $output_dir,
            '--replication-access-uri' => "file://$tmp",
            '--current-time' => $current_time,
        );
    };

    my $test_sitemap_index = sub {
        my ($expected) = @_;

        my $file = 'sitemap-index.xml';
        my $map = WWW::SitemapIndex::XML->new;
        $map->load(location => File::Spec->catfile($output_dir, $file));

        my $got = [
            sort_by { $_->{loc} }
            (map +{ loc => $_->loc, lastmod => $_->lastmod }, $map->sitemaps)
        ];

        $expected = [sort_by { $_->{loc} } @{$expected}];

        cmp_deeply($got, $expected, $file);
    };

    my $test_sitemap = sub {
        my ($file, $expected) = @_;

        my $map = WWW::Sitemap::XML->new;
        $map->load(location => File::Spec->catfile($output_dir, $file));

        my $got = [
            sort_by { $_->{loc} }
            (map +{ loc      => $_->loc,
                    priority => $_->priority,
                    lastmod  => $_->lastmod }, $map->urls)
        ];

        cmp_deeply($got, $expected, $file);
    };

    my $build_time1 = '2015-10-03T20:00:00.000000Z';
    $build_overall->($build_time1);

    $test_sitemap_index->([
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-events.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-works.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1.xml', lastmod => $build_time1},
    ]);

    $test_sitemap->('sitemap-artist-1.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b',
        priority => undef,
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-all.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b?all=1',
        priority => undef,
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-aliases.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/aliases',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-details.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/details',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-events.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/events',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-recordings.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-recordings-standalone.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings?standalone=1',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-recordings-video.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings?video=1',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-relationships.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/relationships',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-releases.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/releases',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-releases-va.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/releases?va=1',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-va.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b?va=1',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-va-all.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b?va=1&all=1',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-artist-1-works.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/works',
        priority => '0.1',
        lastmod => undef,
    }]);

    my $build_packet = sub {
        my ($number, $pending, $pendingdata) = @_;

        $pending = shell_quote($pending);
        $pendingdata = shell_quote($pendingdata);
        my $replication_info = shell_quote(qq({"last_packet": "replication-$number.tar.bz2"}));

        system "echo $replication_info > $tmp/replication-info";
        system "mkdir -p $tmp/mbdump";
        system "echo $pending > $tmp/mbdump/dbmirror_pending";
        system "echo $pendingdata > $tmp/mbdump/dbmirror_pendingdata";
        system "tar -C $tmp -cf - mbdump | bzip2 > $tmp/replication-$number.tar.bz2";
    };

    my $dbmirror_pending = qq(1\t"musicbrainz"."artist"\tu\t1);

    # Lines must have a trailing space.
    chomp (my $dbmirror_pendingdata = <<"EOF");
1\tt\t"id"='1'\x{20}
1\tf\t"id"='1' "name"='B' "last_updated"='2015-10-03 20:03:56.069908+00'\x{20}
EOF

    $exec_sql->(q(UPDATE artist SET name = 'B' WHERE id = 1;));
    $build_packet->(1, $dbmirror_pending, $dbmirror_pendingdata);

    my $build_time2 = '2015-10-03T21:02:50.000000Z';
    $build_incremental->($build_time2);

    $test_sitemap_index->([
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-events.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-works.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships-incremental.xml', lastmod => $build_time2},
    ]);

    $test_sitemap->('sitemap-artist-1-aliases-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/aliases',
        priority => '0.1',
        lastmod => '2015-10-03T20:03:56.069908Z',
    }]);

    $test_sitemap->('sitemap-artist-1-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b',
        priority => undef,
        lastmod => '2015-10-03T20:03:56.069908Z',
    }]);

    $test_sitemap->('sitemap-artist-1-recordings-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings',
        priority => '0.1',
        lastmod => '2015-10-03T20:03:56.069908Z',
    }]);

    $test_sitemap->('sitemap-artist-1-recordings-standalone-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings?standalone=1',
        priority => '0.1',
        lastmod => '2015-10-03T20:03:56.069908Z',
    }]);

    $test_sitemap->('sitemap-artist-1-recordings-video-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings?video=1',
        priority => '0.1',
        lastmod => '2015-10-03T20:03:56.069908Z',
    }]);

    $test_sitemap->('sitemap-artist-1-relationships-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/relationships',
        priority => '0.1',
        lastmod => '2015-10-03T20:03:56.069908Z',
    }]);

    # Insert some works, and make sure they're picked up as changes.
    chomp ($dbmirror_pending = <<"EOF");
1\t"musicbrainz"."work"\ti\t1
2\t"musicbrainz"."work"\ti\t1
3\t"musicbrainz"."work"\ti\t1
EOF

    chomp ($dbmirror_pendingdata = <<"EOF");
1\tt\t"id"='1'\x{20}
1\tf\t"id"='1' "name"='A' "gid"='daf4327f-19a0-450b-9448-e0ea1c707136' "last_updated"='2015-10-04 02:03:04.070000+00'\x{20}
2\tt\t"id"='2'\x{20}
2\tf\t"id"='2' "name"='B' "gid"='b6c76104-d64c-4883-b395-c74f782b751c' "last_updated"='2015-10-04 01:02:03.060000+00'\x{20}
3\tt\t"id"='3'\x{20}
3\tf\t"id"='3' "name"='C' "gid"='79e0f9b8-db97-4bfb-9995-217478dd6c3e' "last_updated"='2015-10-04 00:01:02.050000+00'\x{20}
EOF

    $exec_sql->(<<~'SQL');
        INSERT INTO work (id, gid, name)
            VALUES (1, 'daf4327f-19a0-450b-9448-e0ea1c707136', 'A'),
                   (2, 'b6c76104-d64c-4883-b395-c74f782b751c', 'B'),
                   (3, '79e0f9b8-db97-4bfb-9995-217478dd6c3e', 'C');
        SQL
    $build_packet->(2, $dbmirror_pending, $dbmirror_pendingdata);

    my $build_time3 = '2015-10-04T03:33:33.030000Z';
    $build_incremental->($build_time3);

    $test_sitemap_index->([
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-events.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-works.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-work-1-aliases-incremental.xml', lastmod => $build_time3},
        {loc => 'https://musicbrainz.org/sitemap-work-1-incremental.xml', lastmod => $build_time3},
    ]);

    $test_sitemap->('sitemap-work-1-aliases-incremental.xml', [
        {
            loc => 'https://musicbrainz.org/work/79e0f9b8-db97-4bfb-9995-217478dd6c3e/aliases',
            priority => '0.1',
            lastmod => '2015-10-04T00:01:02.050000Z',
        },
        {
            loc => 'https://musicbrainz.org/work/b6c76104-d64c-4883-b395-c74f782b751c/aliases',
            priority => '0.1',
            lastmod => '2015-10-04T01:02:03.060000Z',
        },
        {
            loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136/aliases',
            priority => '0.1',
            lastmod => '2015-10-04T02:03:04.070000Z',
        },
    ]);

    $test_sitemap->('sitemap-work-1-incremental.xml', [
        {
            loc => 'https://musicbrainz.org/work/79e0f9b8-db97-4bfb-9995-217478dd6c3e',
            priority => undef,
            lastmod => '2015-10-04T00:01:02.050000Z',
        },
        {
            loc => 'https://musicbrainz.org/work/b6c76104-d64c-4883-b395-c74f782b751c',
            priority => undef,
            lastmod => '2015-10-04T01:02:03.060000Z',
        },
        {
            loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136',
            priority => undef,
            lastmod => '2015-10-04T02:03:04.070000Z',
        },
    ]);

    # Insert an ISWC for the first work, a composer relationship for the
    # second, and change the name of the third. Make sure it updates the
    # works' lastmod dates.
    $dbmirror_pending = '';
    chomp ($dbmirror_pending = <<"EOF");
1\t"musicbrainz"."iswc"\ti\t1
2\t"musicbrainz"."link"\ti\t2
3\t"musicbrainz"."l_artist_work"\ti\t2
4\t"musicbrainz"."work"\tu\t3
EOF

    chomp ($dbmirror_pendingdata = <<"EOF");
1\tt\t"id"='1'\x{20}
1\tf\t"id"='1' "work"='1' "iswc"='T-100.000.000-1' "created"='2015-10-05 06:54:32.101234-05'\x{20}
2\tt\t"id"='1'\x{20}
2\tf\t"id"='1' "id"='1' "link_type"='168' "begin_date_year"= "begin_date_month"= "begin_date_day"= "end_date_year"= "end_date_month"= "end_date_day"= "attribute_count"='0' "created"='2017-04-05 01:07:52.449236+00' "ended"='f'\x{20}
3\tt\t"id"='1'\x{20}
3\tf\t"id"='1' "id"='1' "link"='1' "entity0"='1' "entity1"='2' "edits_pending"='0' "last_updated"='2017-04-05 00:59:46.503449+00' "link_order"='0' "entity0_credit"='' "entity1_credit"=''\x{20}
4\tt\t"id"='3' "type"= "language"=\x{20}
4\tf\t"id"='3' "gid"='79e0f9b8-db97-4bfb-9995-217478dd6c3e' "name"='C?' "type"= "comment"='' "edits_pending"='0' "last_updated"='2017-04-05 01:12:36.172561+00' "language"=\x{20}
EOF

    $exec_sql->(<<~'SQL');
        INSERT INTO iswc (id, work, iswc, created)
            VALUES (1, 1, 'T-100.000.000-1', '2015-10-05 06:54:32.101234-05');
        INSERT INTO link (id, link_type, attribute_count, ended, created)
            VALUES (1, 168, 0, 'f', '2017-04-05 01:07:52.449236+00');
        INSERT INTO l_artist_work (id, link, entity0, entity1, last_updated)
            VALUES (1, 1, 1, 2, '2017-04-05 00:59:46.503449+00');
        UPDATE work SET name = 'C?' WHERE id = 3;
        SQL
    $build_packet->(3, $dbmirror_pending, $dbmirror_pendingdata);

    my $build_time4 = '2015-10-05T13:59:59.000123Z';
    $build_incremental->($build_time4);

    $test_sitemap->('sitemap-work-1-aliases-incremental.xml', [
        {
            loc => 'https://musicbrainz.org/work/79e0f9b8-db97-4bfb-9995-217478dd6c3e/aliases',
            priority => '0.1',
            lastmod => '2017-04-05T01:12:36.172561Z',
        },
        {
            loc => 'https://musicbrainz.org/work/b6c76104-d64c-4883-b395-c74f782b751c/aliases',
            priority => '0.1',
            lastmod => '2015-10-04T01:02:03.060000Z',
        },
        {
            loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136/aliases',
            priority => '0.1',
            lastmod => '2015-10-05T11:54:32.101234Z',
        },
    ]);

    $test_sitemap->('sitemap-work-1-incremental.xml', [
        {
            loc => 'https://musicbrainz.org/work/79e0f9b8-db97-4bfb-9995-217478dd6c3e',
            priority => undef,
            lastmod => '2017-04-05T01:12:36.172561Z',
        },
        {
            loc => 'https://musicbrainz.org/work/b6c76104-d64c-4883-b395-c74f782b751c',
            priority => undef,
            lastmod => '2017-04-05T00:59:46.503449Z',
        },
        {
            loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136',
            priority => undef,
            lastmod => '2015-10-05T11:54:32.101234Z',
        },
    ]);

    $test_sitemap_index->([
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-events.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-works.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-work-1-aliases-incremental.xml', lastmod => $build_time4},
        {loc => 'https://musicbrainz.org/sitemap-work-1-incremental.xml', lastmod => $build_time4},
    ]);

    # Rebuild overall sitemaps.
    my $build_time5 = '2015-10-05T19:22:44.112334Z';
    $build_overall->($build_time5);

    $test_sitemap_index->([
        # ----- Pages with JSON-LD had their lastmod's updated.
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-works.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-work-1-aliases.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-work-1-details.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-work-1.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-work-1-recordings.xml', lastmod => $build_time5},
        # -----

        {loc => 'https://musicbrainz.org/sitemap-artist-1-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-events.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships-incremental.xml', lastmod => $build_time2},
        {loc => 'https://musicbrainz.org/sitemap-work-1-aliases-incremental.xml', lastmod => $build_time4},
        {loc => 'https://musicbrainz.org/sitemap-work-1-incremental.xml', lastmod => $build_time4},
    ]);

    # Push an empty replication packet and rebuild incremental
    # sitemaps. Since no changes were made since the most recent overall build,
    # they should all be removed.
    $build_packet->(4, '', '');

    my $build_time6 = '2015-10-06T10:11:22.440044Z';
    $build_incremental->($build_time6);

    $test_sitemap_index->([
        {loc => 'https://musicbrainz.org/sitemap-artist-1-aliases.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-standalone.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings-video.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-recordings.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-relationships.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-events.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va-all.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-va.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-artist-1-works.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-work-1-aliases.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-work-1.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-work-1-details.xml', lastmod => $build_time5},
        {loc => 'https://musicbrainz.org/sitemap-work-1-recordings.xml', lastmod => $build_time5},
    ]);

    # Insert a medium with more than 10 discs, and another with 1 disc
    # but more than 100 tracks. These should be paged appropriately.
    $dbmirror_pending = '';
    chomp ($dbmirror_pending = <<"EOF");
1\t"musicbrainz"."release_group"\ti\t1
2\t"musicbrainz"."release"\ti\t1
3\t"musicbrainz"."medium"\ti\t1
4\t"musicbrainz"."medium"\ti\t1
5\t"musicbrainz"."medium"\ti\t1
6\t"musicbrainz"."medium"\ti\t1
7\t"musicbrainz"."medium"\ti\t1
8\t"musicbrainz"."medium"\ti\t1
9\t"musicbrainz"."medium"\ti\t1
10\t"musicbrainz"."medium"\ti\t1
11\t"musicbrainz"."medium"\ti\t1
12\t"musicbrainz"."medium"\ti\t1
13\t"musicbrainz"."medium"\ti\t1
14\t"musicbrainz"."medium"\ti\t1
15\t"musicbrainz"."release"\ti\t2
16\t"musicbrainz"."medium"\ti\t2
EOF

    # No medium position 12 on the 12-disc medium. (Jumps from 11 to 13.)
    # This tests that /disc/n correctly uses the positions for n.
    chomp ($dbmirror_pendingdata = <<"EOF");
1\tf\t"id"='1' "gid"='b8f8a738-f75c-43df-9f3f-7afb3ceb5173' "name"='R' "artist_credit"='10' "last_updated"='2021-06-10 20:59:59.571049+00'\x{20}
2\tf\t"id"='1' "gid"='692c97b4-e9bb-4400-8afe-34d778064f28' "name"='R' "artist_credit"='10' "release_group"='1' "last_updated"='2021-06-10 20:59:59.571049+00'\x{20}
3\tf\t"id"='1' "release"='1' "position"='1' "track_count"='1'\x{20}
4\tf\t"id"='2' "release"='1' "position"='1' "track_count"='1'\x{20}
5\tf\t"id"='3' "release"='1' "position"='3' "track_count"='1'\x{20}
6\tf\t"id"='4' "release"='1' "position"='4' "track_count"='1'\x{20}
7\tf\t"id"='5' "release"='1' "position"='5' "track_count"='1'\x{20}
8\tf\t"id"='6' "release"='1' "position"='6' "track_count"='1'\x{20}
9\tf\t"id"='7' "release"='1' "position"='7' "track_count"='1'\x{20}
10\tf\t"id"='8' "release"='1' "position"='8' "track_count"='1'\x{20}
11\tf\t"id"='9' "release"='1' "position"='9' "track_count"='1'\x{20}
12\tf\t"id"='10' "release"='1' "position"='10' "track_count"='1'\x{20}
13\tf\t"id"='11' "release"='1' "position"='11' "track_count"='1'\x{20}
14\tf\t"id"='12' "release"='1' "position"='13' "track_count"='1'\x{20}
15\tf\t"id"='2' "gid"='996d3d48-0cfa-4d30-9031-ea50d806b88a' "name"='R2' "artist_credit"='10' "release_group"='1' "last_updated"='2021-06-10 20:59:59.571049+00'\x{20}
16\tf\t"id"='13' "release"='2' "position"='1' "track_count"='102'\x{20}
EOF

    $exec_sql->(<<~'SQL');
        INSERT INTO release_group (id, gid, name, artist_credit, last_updated)
            VALUES (1, 'b8f8a738-f75c-43df-9f3f-7afb3ceb5173', 'R', 1, '2021-06-10 20:59:59.571049+00');

        INSERT INTO release (id, gid, name, artist_credit, release_group, last_updated)
            VALUES (1, '692c97b4-e9bb-4400-8afe-34d778064f28', 'R', 1, 1, '2021-06-10 20:59:59.571049+00');

        INSERT INTO medium (id, release, position, track_count)
            VALUES (1, 1, 1, 1),
                   (2, 1, 2, 1),
                   (3, 1, 3, 1),
                   (4, 1, 4, 1),
                   (5, 1, 5, 1),
                   (6, 1, 6, 1),
                   (7, 1, 7, 1),
                   (8, 1, 8, 1),
                   (9, 1, 9, 1),
                   (10, 1, 10, 1),
                   (11, 1, 11, 1),

                   (12, 1, 13, 1);
        SQL

    $exec_sql->(<<~'SQL');
        INSERT INTO release (id, gid, name, artist_credit, release_group, last_updated)
            VALUES (2, '996d3d48-0cfa-4d30-9031-ea50d806b88a', 'R2', 1, 1, '2021-06-10 20:59:59.571049+00');

        INSERT INTO medium (id, release, position, track_count)
            VALUES (13, 2, 1, 102);
        SQL

    $build_packet->(5, $dbmirror_pending, $dbmirror_pendingdata);

    my $build_time7 = '2021-06-10T21:19:05.442098Z';
    $build_incremental->($build_time7);

    $test_sitemap->('sitemap-release-1-aliases-incremental.xml', [
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28/aliases',
            'priority' => '0.1',
        },
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release/996d3d48-0cfa-4d30-9031-ea50d806b88a/aliases',
            'priority' => '0.1',
        },
    ]);

    $test_sitemap->('sitemap-release-1-incremental.xml', [
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28',
            'priority' => undef,
        },
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release/996d3d48-0cfa-4d30-9031-ea50d806b88a',
            'priority' => undef,
        },
    ]);

    $test_sitemap->('sitemap-release-1-cover-art-incremental.xml', [
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28/cover-art',
            'priority' => '0.1',
        },
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release/996d3d48-0cfa-4d30-9031-ea50d806b88a/cover-art',
            'priority' => '0.1',
        },
    ]);

    $test_sitemap->('sitemap-release_group-1-aliases-incremental.xml', [
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release-group/b8f8a738-f75c-43df-9f3f-7afb3ceb5173/aliases',
            'priority' => '0.1',
        },
    ]);

    $test_sitemap->('sitemap-release_group-1-incremental.xml', [
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release-group/b8f8a738-f75c-43df-9f3f-7afb3ceb5173',
            'priority' => undef,
        },
    ]);

    $build_overall->($build_time7);

    $test_sitemap->('sitemap-release-1.xml', [
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28',
            'priority' => undef,
        },
        {
            'lastmod' => '2021-06-10T20:59:59.571049Z',
            'loc' => 'https://musicbrainz.org/release/996d3d48-0cfa-4d30-9031-ea50d806b88a',
            'priority' => undef,
        },
    ]);

    $test_sitemap->('sitemap-release-1-disc.xml', [
        {
            'lastmod' => undef,
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28/disc/11?page=1',
            'priority' => undef,
        },
        {
            'lastmod' => undef,
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28/disc/13?page=1',
            'priority' => undef,
        },
        {
            'lastmod' => undef,
            'loc' => 'https://musicbrainz.org/release/996d3d48-0cfa-4d30-9031-ea50d806b88a/disc/1?page=2',
            'priority' => undef,
        },
    ]);

    $exec_sql->(<<~'SQL');
        TRUNCATE artist CASCADE;
        TRUNCATE work CASCADE;
        TRUNCATE sitemaps.control;
        TRUNCATE sitemaps.tmp_checked_entities;
        SQL
};

run_me;
done_testing;
