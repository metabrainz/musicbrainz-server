package t::MusicBrainz::Server::Sitemap;

use DBDefs;
use File::Spec;
use File::Temp qw( tempdir );
use List::UtilsBy qw( sort_by );
use String::ShellQuote;
use Test::Deep qw( cmp_deeply ignore );
use Test::Routine;
use Test::More;
use WWW::Sitemap::XML;
use WWW::SitemapIndex::XML;

test 'Sitemap build scripts' => sub {
    # Because this test invokes external scripts that rely on certain test data
    # existing, it can't use t::Context or anything that would be contained
    # inside a transaction.

    my $root = DBDefs->MB_SERVER_ROOT;
    my $psql = File::Spec->catfile($root, 'admin/psql');

    my $exec_sql = sub {
        my $sql = shell_quote(shift);

        system 'sh', '-c' => "echo $sql | $psql TEST";
    };

    $exec_sql->(<<EOSQL);
INSERT INTO artist (id, gid, name, sort_name)
VALUES (1, '30238ead-59fa-41e2-a7ab-b7f6e6363c4b', 'A', 'A');
EOSQL

    my $tmp = tempdir("t-sitemaps-XXXXXXXX", DIR => '/tmp', CLEANUP => 1);

    system (
        File::Spec->catfile($root, 'admin/BuildSitemaps.pl'),
        '--nocompress',
        '--database' => 'TEST',
        '--output-dir' => $tmp,
    );

    my $test_sitemap_index = sub {
        my ($expected) = @_;

        my $file = 'sitemap-index.xml';
        my $map = WWW::SitemapIndex::XML->new;
        $map->load(location => File::Spec->catfile($tmp, $file));

        my $got = [
            sort_by { $_->{loc} }
            (map +{ loc => $_->loc, lastmod => $_->lastmod }, $map->sitemaps)
        ];

        $expected = [map +{ loc => "https://musicbrainz.org/$_", lastmod => ignore() }, @{$expected}];

        cmp_deeply($got, $expected, $file);
    };

    my $test_sitemap = sub {
        my ($file, $expected) = @_;

        my $map = WWW::Sitemap::XML->new;
        $map->load(location => File::Spec->catfile($tmp, $file));

        my $got = [
            sort_by { $_->{loc} }
            (map +{ loc      => $_->loc,
                    priority => $_->priority,
                    lastmod  => $_->lastmod }, $map->urls)
        ];

        cmp_deeply($got, $expected, $file);
    };

    $test_sitemap_index->([
        'sitemap-artist-1-aliases.xml',
        'sitemap-artist-1-all.xml',
        'sitemap-artist-1-details.xml',
        'sitemap-artist-1-events.xml',
        'sitemap-artist-1-recordings-standalone.xml',
        'sitemap-artist-1-recordings-video.xml',
        'sitemap-artist-1-recordings.xml',
        'sitemap-artist-1-relationships.xml',
        'sitemap-artist-1-releases-va.xml',
        'sitemap-artist-1-releases.xml',
        'sitemap-artist-1-va-all.xml',
        'sitemap-artist-1-va.xml',
        'sitemap-artist-1-works.xml',
        'sitemap-artist-1.xml',
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
        system "tar -C $tmp -cyf - mbdump > $tmp/replication-$number.tar.bz2";
    };

    my $build_incremental = sub {
        system (
            File::Spec->catfile($root, 'admin/BuildIncrementalSitemaps.pl'),
            '--nocompress',
            '--database' => 'TEST',
            '--output-dir' => $tmp,
            '--replication-access-uri' => "file://$tmp",
        );
    };

    my $dbmirror_pending = qq(1\t"musicbrainz"."artist"\tu\t1);

    # Lines must have a trailing space.
    chomp (my $dbmirror_pendingdata = <<"EOF");
1\tt\t"id"='1'\x{20}
1\tf\t"id"='1' "name"='B' "last_updated"='2015-10-03 20:03:56.069908+00'\x{20}
EOF

    $exec_sql->("UPDATE artist SET name = 'B' WHERE id = 1;");
    $build_packet->(1, $dbmirror_pending, $dbmirror_pendingdata);
    $build_incremental->();

    $test_sitemap_index->([
        'sitemap-artist-1-aliases-incremental.xml',
        'sitemap-artist-1-aliases.xml',
        'sitemap-artist-1-all.xml',
        'sitemap-artist-1-details.xml',
        'sitemap-artist-1-events.xml',
        'sitemap-artist-1-incremental.xml',
        'sitemap-artist-1-recordings-incremental.xml',
        'sitemap-artist-1-recordings-standalone-incremental.xml',
        'sitemap-artist-1-recordings-standalone.xml',
        'sitemap-artist-1-recordings-video-incremental.xml',
        'sitemap-artist-1-recordings-video.xml',
        'sitemap-artist-1-recordings.xml',
        'sitemap-artist-1-relationships-incremental.xml',
        'sitemap-artist-1-relationships.xml',
        'sitemap-artist-1-releases-va.xml',
        'sitemap-artist-1-releases.xml',
        'sitemap-artist-1-va-all.xml',
        'sitemap-artist-1-va.xml',
        'sitemap-artist-1-works.xml',
        'sitemap-artist-1.xml',
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

    # Insert a work, make sure it's picked up as a change.
    $dbmirror_pending = qq(1\t"musicbrainz"."work"\ti\t1);

    chomp ($dbmirror_pendingdata = <<"EOF");
1\tt\t"id"='1'\x{20}
1\tf\t"id"='1' "name"='A' "gid"='daf4327f-19a0-450b-9448-e0ea1c707136' "last_updated"='2015-10-04 02:03:04.070000+00'\x{20}
EOF

    $exec_sql->(<<EOSQL);
INSERT INTO work (id, gid, name)
VALUES (1, 'daf4327f-19a0-450b-9448-e0ea1c707136', 'A');
EOSQL
    $build_packet->(2, $dbmirror_pending, $dbmirror_pendingdata);
    $build_incremental->();

    $test_sitemap_index->([
        'sitemap-artist-1-aliases-incremental.xml',
        'sitemap-artist-1-aliases.xml',
        'sitemap-artist-1-all.xml',
        'sitemap-artist-1-details.xml',
        'sitemap-artist-1-events.xml',
        'sitemap-artist-1-incremental.xml',
        'sitemap-artist-1-recordings-incremental.xml',
        'sitemap-artist-1-recordings-standalone-incremental.xml',
        'sitemap-artist-1-recordings-standalone.xml',
        'sitemap-artist-1-recordings-video-incremental.xml',
        'sitemap-artist-1-recordings-video.xml',
        'sitemap-artist-1-recordings.xml',
        'sitemap-artist-1-relationships-incremental.xml',
        'sitemap-artist-1-relationships.xml',
        'sitemap-artist-1-releases-va.xml',
        'sitemap-artist-1-releases.xml',
        'sitemap-artist-1-va-all.xml',
        'sitemap-artist-1-va.xml',
        'sitemap-artist-1-works.xml',
        'sitemap-artist-1.xml',
        'sitemap-work-1-aliases-incremental.xml',
        'sitemap-work-1-incremental.xml',
    ]);

    $test_sitemap->('sitemap-work-1-aliases-incremental.xml', [{
        loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136/aliases',
        priority => '0.1',
        lastmod => '2015-10-04T02:03:04.070000Z',
    }]);

    $test_sitemap->('sitemap-work-1-incremental.xml', [{
        loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136',
        priority => undef,
        lastmod => '2015-10-04T02:03:04.070000Z',
    }]);

    $exec_sql->(<<EOSQL);
TRUNCATE artist CASCADE;
TRUNCATE work CASCADE;
TRUNCATE sitemaps.control;
TRUNCATE sitemaps.tmp_checked_entities;
EOSQL
};

1;
