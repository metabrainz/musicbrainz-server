use strict;
use warnings;

use DateTime;
use DateTime::Format::Pg;
use DateTime::Format::W3CDTF;
use File::Spec;
use File::Temp qw( tempdir );
use lib 't/lib';
use List::AllUtils qw( sort_by );
use Test::Deep qw( cmp_deeply );
use Test::Routine;
use Test::Routine::Util;
use Test::More;
use WWW::Sitemap::XML;
use WWW::SitemapIndex::XML;

use DBDefs;
use MusicBrainz::Server::Context;
use aliased 't::script::ReplicationTest';

$ENV{MUSICBRAINZ_RUNNING_TESTS} = 1;

test 'Sitemap build scripts' => sub {
    my $root = DBDefs->MB_SERVER_ROOT;

    # Sitemaps run entirely on the master, so we do not make use of
    # `mirror_c`. We only use `ReplicationTest` to generate replication
    # packets consumed by the incremental sitemaps builder.
    my $test = ReplicationTest->new;
    my $master_c = $test->master_c;

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
        DO $$
        BEGIN
            EXECUTE 'ALTER DATABASE ' || current_database() ||
                ' SET TIMEZONE TO ''UTC''';
        END $$;

        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (3, '30238ead-59fa-41e2-a7ab-b7f6e6363c4b', 'A', 'A');

        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (1, 'A', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

        INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
            VALUES (1, 0, 3, 'A', '');
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    my $tmp = tempdir('t-sitemaps-XXXXXXXX', DIR => '/tmp', CLEANUP => 1);
    my $output_dir = File::Spec->catdir($tmp, 'sitemaps');
    system 'mkdir', '-p', $output_dir;

    my $build_overall = sub {
        my ($current_time) = @_;

        system (
            File::Spec->catfile($root, 'admin/BuildSitemaps.pl'),
            '--nocompress',
            '--database' => 'TEST_MASTER',
            '--output-dir' => $output_dir,
            '--current-time' => $current_time,
        );
    };

    my $build_incremental = sub {
        my ($current_time) = @_;

        system (
            File::Spec->catfile($root, 'admin/BuildIncrementalSitemaps.pl'),
            '--nocompress',
            '--database' => 'TEST_MASTER',
            '--output-dir' => $output_dir,
            '--replication-access-uri' => 'file://' .
                $test->output_dir,
            '--current-time' => $current_time,
            '--foreign-keys-dump' => $foreign_keys_dump,
        );
    };

    my $test_sitemap_index = sub {
        my ($expected) = @_;

        my $file = 'sitemap-index.xml';
        my $map = WWW::SitemapIndex::XML->new;
        $map->load(location => File::Spec->catfile($output_dir, $file));

        my $got = [
            sort_by { $_->{loc} }
            (map +{ loc => $_->loc, lastmod => $_->lastmod }, $map->sitemaps),
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
                    lastmod  => $_->lastmod }, $map->urls),
        ];

        cmp_deeply($got, $expected, $file);
    };

    my $build_time1 = DateTime::Format::W3CDTF->format_datetime(DateTime->now);
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
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1.xml', lastmod => $build_time1},
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

    $test_sitemap->('sitemap-instrument-1-aliases.xml', [{
        loc => 'https://musicbrainz.org/instrument/b3eac5f9-7859-4416-ac39-7154e2e8d348/aliases',
        priority => '0.3',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-instrument-1-details.xml', [{
        loc => 'https://musicbrainz.org/instrument/b3eac5f9-7859-4416-ac39-7154e2e8d348/details',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-instrument-1-recordings.xml', [{
        loc => 'https://musicbrainz.org/instrument/b3eac5f9-7859-4416-ac39-7154e2e8d348/recordings',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-instrument-1-releases.xml', [{
        loc => 'https://musicbrainz.org/instrument/b3eac5f9-7859-4416-ac39-7154e2e8d348/releases',
        priority => '0.1',
        lastmod => undef,
    }]);

    $test_sitemap->('sitemap-instrument-1.xml', [{
        loc => 'https://musicbrainz.org/instrument/b3eac5f9-7859-4416-ac39-7154e2e8d348',
        priority => undef,
        lastmod => undef,
    }]);

    # Update the name.
    $master_c->sql->auto_commit;
    $master_c->sql->do('UPDATE artist SET name = \'B\' WHERE id = 3');

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    my $build_time2 = DateTime::Format::W3CDTF->format_datetime(DateTime->now);
    my $lastmod_time2 = DateTime::Format::W3CDTF->format_datetime(
        DateTime::Format::Pg->parse_datetime($master_c->sql->select_single_value(
            'SELECT last_updated FROM artist WHERE id = 3',
        )));
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
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1.xml', lastmod => $build_time1},
    ]);

    $test_sitemap->('sitemap-artist-1-aliases-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/aliases',
        priority => '0.1',
        lastmod => $lastmod_time2,
    }]);

    $test_sitemap->('sitemap-artist-1-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b',
        priority => undef,
        lastmod => $lastmod_time2,
    }]);

    $test_sitemap->('sitemap-artist-1-recordings-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings',
        priority => '0.1',
        lastmod => $lastmod_time2,
    }]);

    $test_sitemap->('sitemap-artist-1-recordings-standalone-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings?standalone=1',
        priority => '0.1',
        lastmod => $lastmod_time2,
    }]);

    $test_sitemap->('sitemap-artist-1-recordings-video-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/recordings?video=1',
        priority => '0.1',
        lastmod => $lastmod_time2,
    }]);

    $test_sitemap->('sitemap-artist-1-relationships-incremental.xml', [{
        loc => 'https://musicbrainz.org/artist/30238ead-59fa-41e2-a7ab-b7f6e6363c4b/relationships',
        priority => '0.1',
        lastmod => $lastmod_time2,
    }]);

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

    my $build_time3 = DateTime::Format::W3CDTF->format_datetime(DateTime->now);
    my $lastmod_time3 = DateTime::Format::W3CDTF->format_datetime(
        DateTime::Format::Pg->parse_datetime($master_c->sql->select_single_value(
            'SELECT last_updated FROM work WHERE id = 1',
        )));
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
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-work-1-aliases-incremental.xml', lastmod => $build_time3},
        {loc => 'https://musicbrainz.org/sitemap-work-1-incremental.xml', lastmod => $build_time3},
    ]);

    $test_sitemap->('sitemap-work-1-aliases-incremental.xml', [
        {
            loc => 'https://musicbrainz.org/work/79e0f9b8-db97-4bfb-9995-217478dd6c3e/aliases',
            priority => '0.1',
            lastmod => $lastmod_time3,
        },
        {
            loc => 'https://musicbrainz.org/work/b6c76104-d64c-4883-b395-c74f782b751c/aliases',
            priority => '0.1',
            lastmod => $lastmod_time3,
        },
        {
            loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136/aliases',
            priority => '0.1',
            lastmod => $lastmod_time3,
        },
    ]);

    $test_sitemap->('sitemap-work-1-incremental.xml', [
        {
            loc => 'https://musicbrainz.org/work/79e0f9b8-db97-4bfb-9995-217478dd6c3e',
            priority => undef,
            lastmod => $lastmod_time3,
        },
        {
            loc => 'https://musicbrainz.org/work/b6c76104-d64c-4883-b395-c74f782b751c',
            priority => undef,
            lastmod => $lastmod_time3,
        },
        {
            loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136',
            priority => undef,
            lastmod => $lastmod_time3,
        },
    ]);

    # Insert an ISWC for the first work, a composer relationship for the
    # second, and change the name of the third. Make sure it updates the
    # works' lastmod dates.
    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        INSERT INTO iswc (id, work, iswc)
             VALUES (1, 1, 'T-100.000.000-1');
        INSERT INTO link (id, link_type, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, attribute_count, ended)
             VALUES (1, 168, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'f');
        INSERT INTO l_artist_work (id, link, entity0, entity1, link_order, entity0_credit, entity1_credit)
             VALUES (1, 1, 3, 2, 0, '', '');
        UPDATE work SET name = 'C?' WHERE id = 3;
        SQL

    $test->master_c->cache->clear;
    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    my $build_time4 = DateTime::Format::W3CDTF->format_datetime(DateTime->now);
    my $lastmod_time4 = DateTime::Format::W3CDTF->format_datetime(
        DateTime::Format::Pg->parse_datetime($master_c->sql->select_single_value(
            'SELECT last_updated FROM work WHERE id = 3',
        )));
    $build_incremental->($build_time4);

    $test_sitemap->('sitemap-work-1-aliases-incremental.xml', [
        {
            loc => 'https://musicbrainz.org/work/79e0f9b8-db97-4bfb-9995-217478dd6c3e/aliases',
            priority => '0.1',
            lastmod => $lastmod_time4,
        },
        {
            loc => 'https://musicbrainz.org/work/b6c76104-d64c-4883-b395-c74f782b751c/aliases',
            priority => '0.1',
            lastmod => $lastmod_time3,
        },
        {
            loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136/aliases',
            priority => '0.1',
            lastmod => $lastmod_time4,
        },
    ]);

    $test_sitemap->('sitemap-work-1-incremental.xml', [
        {
            loc => 'https://musicbrainz.org/work/79e0f9b8-db97-4bfb-9995-217478dd6c3e',
            priority => undef,
            lastmod => $lastmod_time4,
        },
        {
            loc => 'https://musicbrainz.org/work/b6c76104-d64c-4883-b395-c74f782b751c',
            priority => undef,
            lastmod => $lastmod_time4,
        },
        {
            loc => 'https://musicbrainz.org/work/daf4327f-19a0-450b-9448-e0ea1c707136',
            priority => undef,
            lastmod => $lastmod_time4,
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
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-work-1-aliases-incremental.xml', lastmod => $build_time4},
        {loc => 'https://musicbrainz.org/sitemap-work-1-incremental.xml', lastmod => $build_time4},
    ]);

    # Rebuild overall sitemaps.
    my $build_time5 = DateTime::Format::W3CDTF->format_datetime(DateTime->now);
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
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-aliases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-details.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-recordings.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1-releases.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-instrument-1.xml', lastmod => $build_time1},
        {loc => 'https://musicbrainz.org/sitemap-work-1-aliases-incremental.xml', lastmod => $build_time4},
        {loc => 'https://musicbrainz.org/sitemap-work-1-incremental.xml', lastmod => $build_time4},
    ]);

    # Insert a medium with more than 10 discs, and another with 1 disc
    # but more than 100 tracks. These should be paged appropriately.
    #
    # No medium position 12 on the 12-disc medium. (Jumps from 11 to 13.)
    # This tests that /disc/n correctly uses the positions for n.
    $master_c->sql->auto_commit;
    $master_c->sql->do(<<~'SQL');
        INSERT INTO release_group (id, gid, name, artist_credit)
            VALUES (1, 'b8f8a738-f75c-43df-9f3f-7afb3ceb5173', 'R', 1);

        INSERT INTO release (id, gid, name, artist_credit, release_group)
            VALUES (1, '692c97b4-e9bb-4400-8afe-34d778064f28', 'R', 1, 1),
                   (2, '996d3d48-0cfa-4d30-9031-ea50d806b88a', 'R2', 1, 1);

        INSERT INTO medium (id, gid, release, position, track_count)
            VALUES (1, '9153726c-ff28-4c8f-972e-2fd903b37fb2', 1, 1, 1),
                   (2, '27a1a221-00d8-4a4b-9113-1bd799a27254', 1, 2, 1),
                   (3, '5e098342-465e-4e19-8547-f9e3ddd18d16', 1, 3, 1),
                   (4, '3c5ca3c6-eb39-4270-932f-7475eb1879d2', 1, 4, 1),
                   (5, '8a737f34-d87b-4540-bfe9-6e2be05d6cda', 1, 5, 1),
                   (6, '9cea2e0b-d396-4508-b528-87f94389ea67', 1, 6, 1),
                   (7, '62fceb98-2918-4f2d-a0b1-0309f777e7db', 1, 7, 1),
                   (8, 'b969e215-eb89-4aa0-a2fb-38d592a8a2a5', 1, 8, 1),
                   (9, '9665f815-635a-4054-9b86-eb68a48a9152', 1, 9, 1),
                   (10, 'fe7ec5b1-d2f3-4702-a202-90e58f65c071', 1, 10, 1),
                   (11, '915b71ce-147c-4789-8055-7ebed97dfd17', 1, 11, 1),
                   (12, 'b828cdef-914a-41a6-b174-3a6123ec1363', 1, 13, 1),
                   (13, 'f75bc0e9-eba6-43b2-bed5-f97f0b7fd868', 2, 1, 102);
        SQL

    $test->export_all_tables(
        '--without-full-export',
        '--with-replication',
    );

    my $build_time6 = DateTime::Format::W3CDTF->format_datetime(DateTime->now);
    my $lastmod_time6 = DateTime::Format::W3CDTF->format_datetime(
        DateTime::Format::Pg->parse_datetime($master_c->sql->select_single_value(
            'SELECT last_updated FROM release WHERE id = 1',
        )));
    $build_incremental->($build_time6);

    $test_sitemap->('sitemap-release-1-aliases-incremental.xml', [
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28/aliases',
            'priority' => '0.1',
        },
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release/996d3d48-0cfa-4d30-9031-ea50d806b88a/aliases',
            'priority' => '0.1',
        },
    ]);

    $test_sitemap->('sitemap-release-1-incremental.xml', [
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28',
            'priority' => undef,
        },
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release/996d3d48-0cfa-4d30-9031-ea50d806b88a',
            'priority' => undef,
        },
    ]);

    $test_sitemap->('sitemap-release-1-cover-art-incremental.xml', [
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28/cover-art',
            'priority' => '0.1',
        },
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release/996d3d48-0cfa-4d30-9031-ea50d806b88a/cover-art',
            'priority' => '0.1',
        },
    ]);

    $test_sitemap->('sitemap-release_group-1-aliases-incremental.xml', [
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release-group/b8f8a738-f75c-43df-9f3f-7afb3ceb5173/aliases',
            'priority' => '0.1',
        },
    ]);

    $test_sitemap->('sitemap-release_group-1-incremental.xml', [
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release-group/b8f8a738-f75c-43df-9f3f-7afb3ceb5173',
            'priority' => undef,
        },
    ]);

    $build_overall->($build_time6);

    $test_sitemap->('sitemap-release-1.xml', [
        {
            'lastmod' => $lastmod_time6,
            'loc' => 'https://musicbrainz.org/release/692c97b4-e9bb-4400-8afe-34d778064f28',
            'priority' => undef,
        },
        {
            'lastmod' => $lastmod_time6,
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
};

run_me;
done_testing;

1;
