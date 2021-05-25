package MusicBrainz::Server::Sitemap::Overall;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use DBDefs;
use List::Util qw( min );
use Moose;
use MusicBrainz::Script::Utils qw( log );
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use MusicBrainz::Server::Data::Relationship;
use MusicBrainz::Server::Sitemap::Constants qw(
    $MAX_SITEMAP_SIZE
    %SITEMAP_SUFFIX_INFO
);
use POSIX;
use Sql;

extends 'MusicBrainz::Server::Sitemap::Builder';

with 'MooseX::Runnable';
with 'MusicBrainz::Script::Role::TestCacheNamespace';

=head2 create_temporary_tables, fill_temporary_tables, drop_temporary_tables

These functions create, fill with data, and drop, respectively, the temporary
tables used to assist in the process of creating sitemaps.

=cut

sub create_temporary_tables {
    my ($self, $sql) = @_;

    $sql->begin;
    $sql->do(
        "CREATE TEMPORARY TABLE tmp_sitemaps_artist_direct_rgs
             (artist INTEGER,
              rg     INTEGER,
              is_official BOOLEAN NOT NULL,

              PRIMARY KEY (artist, rg))
         ON COMMIT DELETE ROWS");
    $sql->do(
        "CREATE TEMPORARY TABLE tmp_sitemaps_artist_va_rgs
             (artist INTEGER,
              rg     INTEGER,
              is_official BOOLEAN NOT NULL,

              PRIMARY KEY (artist, rg))
         ON COMMIT DELETE ROWS");
    $sql->do(
        "CREATE TEMPORARY TABLE tmp_sitemaps_artist_direct_releases
             (artist  INTEGER,
              release INTEGER,

              PRIMARY KEY (artist, release))
         ON COMMIT DELETE ROWS");
    $sql->do(
        "CREATE TEMPORARY TABLE tmp_sitemaps_artist_va_releases
             (artist  INTEGER,
              release INTEGER,

              PRIMARY KEY (artist, release))
         ON COMMIT DELETE ROWS");
    $sql->do(
        "CREATE TEMPORARY TABLE tmp_sitemaps_artist_recordings
             (artist        INTEGER,
              recording     INTEGER,
              is_video      BOOLEAN NOT NULL,
              is_standalone BOOLEAN NOT NULL,

              PRIMARY KEY (artist, recording))
         ON COMMIT DELETE ROWS");
    $sql->do(
        "CREATE TEMPORARY TABLE tmp_sitemaps_artist_works
             (artist   INTEGER,
              work     INTEGER,

              PRIMARY KEY (artist, work))
         ON COMMIT DELETE ROWS");

    $sql->do(
         "CREATE TEMPORARY TABLE tmp_sitemaps_instrument_recordings
             (instrument INTEGER,
              recording  INTEGER,

              PRIMARY KEY (instrument, recording))
          ON COMMIT DELETE ROWS");
    $sql->do(
         "CREATE TEMPORARY TABLE tmp_sitemaps_instrument_releases
             (instrument INTEGER,
              release  INTEGER,

              PRIMARY KEY (instrument, release))
          ON COMMIT DELETE ROWS");

    $sql->do(
         "CREATE TEMPORARY TABLE tmp_sitemaps_work_recordings_count
             (work INTEGER,
              recordings_count INTEGER,
              PRIMARY KEY (work))
          ON COMMIT DELETE ROWS");
    $sql->commit;
}

sub fill_temporary_tables {
    my ($self, $sql) = @_;

    my $is_official = "(EXISTS (SELECT TRUE FROM release WHERE release.release_group = q.rg AND release.status = '1')
                        OR NOT EXISTS (SELECT 1 FROM release WHERE release.release_group = q.rg AND release.status IS NOT NULL))";

    # Release groups that will appear on the non-VA listings, per artist
    log('Filling tmp_sitemaps_artist_direct_rgs');
    $sql->do("INSERT INTO tmp_sitemaps_artist_direct_rgs (artist, rg, is_official)
                  SELECT artist, rg, $is_official FROM
                  (SELECT DISTINCT artist_credit_name.artist AS artist, release_group.id AS rg
                    FROM release_group
                    JOIN artist_credit_name ON release_group.artist_credit = artist_credit_name.artist_credit) q");

    log('Analyzing tmp_sitemaps_artist_direct_rgs');
    $sql->do("ANALYZE tmp_sitemaps_artist_direct_rgs");

    # Release groups that will appear on the VA listings, per artist. Uses the above temporary table to exclude non-VA appearances.
    log('Filling tmp_sitemaps_artist_va_rgs');
    $sql->do("INSERT INTO tmp_sitemaps_artist_va_rgs (artist, rg, is_official)
                  SELECT artist, rg, $is_official FROM
                  (SELECT DISTINCT artist_credit_name.artist AS artist, release_group.id AS rg
                    FROM release_group
                    JOIN release ON release.release_group = release_group.id
                    JOIN medium ON medium.release = release.id
                    JOIN track ON track.medium = medium.id
                    JOIN artist_credit_name ON track.artist_credit = artist_credit_name.artist_credit
                   WHERE NOT EXISTS (SELECT TRUE FROM tmp_sitemaps_artist_direct_rgs WHERE artist = artist_credit_name.artist AND rg = release_group.id)) q");

    log('Analyzing tmp_sitemaps_artist_va_rgs');
    $sql->do("ANALYZE tmp_sitemaps_artist_va_rgs");

    # Releases that will appear in the non-VA part of the artist releases tab, per artist
    log('Filling tmp_sitemaps_artist_direct_releases');
    $sql->do("INSERT INTO tmp_sitemaps_artist_direct_releases (artist, release)
                  SELECT DISTINCT artist_credit_name.artist AS artist, release.id AS release
                    FROM release JOIN artist_credit_name ON release.artist_credit = artist_credit_name.artist_credit");

    log('Analyzing tmp_sitemaps_artist_direct_releases');
    $sql->do("ANALYZE tmp_sitemaps_artist_direct_releases");

    # Releases that will appear in the VA listings instead. Uses above table to exclude non-VA appearances.
    log('Filling tmp_sitemaps_artist_va_releases');
    $sql->do("INSERT INTO tmp_sitemaps_artist_va_releases (artist, release)
                  SELECT DISTINCT artist_credit_name.artist AS artist, release.id AS release
                    FROM release
                    JOIN medium ON medium.release = release.id
                    JOIN track ON track.medium = medium.id
                    JOIN artist_credit_name ON track.artist_credit = artist_credit_name.artist_credit
                   WHERE NOT EXISTS (SELECT TRUE FROM tmp_sitemaps_artist_direct_releases WHERE artist = artist_credit_name.artist AND release = release.id)");

    log('Analyzing tmp_sitemaps_artist_va_releases');
    $sql->do("ANALYZE tmp_sitemaps_artist_va_releases");

    log('Filling tmp_sitemaps_artist_recordings');
    $sql->do("INSERT INTO tmp_sitemaps_artist_recordings (artist, recording, is_video, is_standalone)
                  WITH track_recordings (recording) AS (
                      SELECT DISTINCT recording FROM track
                  )
                  SELECT DISTINCT ON (artist, recording)
                      artist_credit_name.artist AS artist, recording.id as recording,
                      video as is_video, track_recordings.recording IS NULL AS is_standalone
                    FROM recording
                    JOIN artist_credit_name ON recording.artist_credit = artist_credit_name.artist_credit
                    LEFT JOIN track_recordings ON recording.id = track_recordings.recording");

    log('Analyzing tmp_sitemaps_artist_recordings');
    $sql->do("ANALYZE tmp_sitemaps_artist_recordings");

    # Works linked directly to artists as well as via recording ACs.
    log('Filling tmp_sitemaps_artist_works');
    $sql->do("INSERT INTO tmp_sitemaps_artist_works (artist, work)
                  SELECT entity0 AS artist, entity1 AS work from l_artist_work
                   UNION DISTINCT
                  SELECT tsar.artist AS artist, entity1 AS work
                    FROM tmp_sitemaps_artist_recordings tsar
                    JOIN l_recording_work ON tsar.recording = l_recording_work.entity0");

    log('Analyzing tmp_sitemaps_artist_works');
    $sql->do("ANALYZE tmp_sitemaps_artist_works");

    # Instruments linked to recordings via artist-recording relationship
    # attributes. Matches Data::Recording, which also ignores other tables
    log('Filling tmp_sitemaps_instrument_recordings');
    $sql->do("INSERT INTO tmp_sitemaps_instrument_recordings (instrument, recording)
                  SELECT DISTINCT instrument.id AS instrument, l_artist_recording.entity1 AS recording
                    FROM instrument
                    JOIN link_attribute_type ON link_attribute_type.gid = instrument.gid
                    JOIN link_attribute ON link_attribute.attribute_type = link_attribute_type.id
                    JOIN l_artist_recording ON l_artist_recording.link = link_attribute.link");

    log('Analyzing tmp_sitemaps_instrument_recordings');
    $sql->do("ANALYZE tmp_sitemaps_instrument_recordings");

    # Instruments linked to releases via artist-release relationship
    # attributes. Matches Data::Release, which also ignores other tables
    log('Filling tmp_sitemaps_instrument_releases');
    $sql->do("INSERT INTO tmp_sitemaps_instrument_releases (instrument, release)
                  SELECT DISTINCT instrument.id AS instrument, l_artist_release.entity1 AS release
                    FROM instrument
                    JOIN link_attribute_type ON link_attribute_type.gid = instrument.gid
                    JOIN link_attribute ON link_attribute.attribute_type = link_attribute_type.id
                    JOIN l_artist_release ON l_artist_release.link = link_attribute.link");

    log('Analyzing tmp_sitemaps_instrument_releases');
    $sql->do("ANALYZE tmp_sitemaps_instrument_releases");

    # Recordings linked to works via performance / "recording of"
    # relationships, but only where the number of recordings per work
    # exceeds 100 (`DEFAULT_LOAD_PAGED_LIMIT`). We already output the
    # first such 100 recordings on the work index page.
    log('Filling tmp_sitemaps_work_recordings_count');
    $sql->do("INSERT INTO tmp_sitemaps_work_recordings_count (work, recordings_count)
                SELECT DISTINCT q.work, q.recordings_count FROM
                    (SELECT lrw.entity1 AS work,
                            count(lrw.entity0) OVER (PARTITION BY lrw.entity1) AS recordings_count
                       FROM l_recording_work lrw
                       JOIN link l ON l.id = lrw.link
                      WHERE l.link_type = 278) q
                 WHERE q.recordings_count > ?",
             $MusicBrainz::Server::Data::Relationship::DEFAULT_LOAD_PAGED_LIMIT);

    log('Analyzing tmp_sitemaps_work_recordings_count');
    $sql->do("ANALYZE tmp_sitemaps_work_recordings_count");
}

sub drop_temporary_tables {
    my ($self, $sql) = @_;

    $sql->begin;
    for my $table (qw( artist_direct_rgs
                       artist_va_rgs
                       artist_direct_releases
                       artist_va_releases
                       artist_recordings
                       artist_works
                       instrument_recordings
                       instrument_releases )) {
        $sql->do(<<~"EOSQL");
            SET client_min_messages TO WARNING;
            DROP TABLE IF EXISTS tmp_sitemaps_$table;
            EOSQL
    }
    $sql->commit;
}

=head2 build_one_entity

The "main loop" function. Takes an entity type, figures out batches to build
and what to build for each batch, then calls out to do it.

=cut

sub build_one_entity {
    my ($self, $c, $entity_type) = @_;

    my $sql = $c->sql;

    # Find the counts in each potential batch of 50,000
    my $raw_batches = $sql->select_list_of_hashes(
        "SELECT batch, count(id) FROM (SELECT id, ceil(id / ?::float) AS batch FROM $entity_type) q GROUP BY batch ORDER BY batch ASC",
        $MAX_SITEMAP_SIZE
    );

    return unless @{$raw_batches};
    my @batches;

    # Exclude the last batch, which should always be its own sitemap.
    #
    # Since sitemaps do a bit of a bundling thing to reach as close to 50,000
    # URLs as possible, it'd be possible that right after a rollover past
    # 50,000 IDs, the new one would be folded into the otherwise-most-recent
    # batch. Since the goal is that each URL only ever starts in its actual
    # batch number and then moves down over time, this ensures that the last
    # batch is always its own sitemap, even if it's few enough it could
    # theoretically be part of the previous one.

    if (scalar @$raw_batches > 1) {
        my $batch = {count => 0, batches => []};
        for my $raw_batch (@{ $raw_batches }[0..scalar @$raw_batches-2]) {
            # Add this potential batch to the previous one if the sum will come out less than 50,000
            # Otherwise create a new batch and push the previous one onto the list.
            if ($batch->{count} + $raw_batch->{count} <= $MAX_SITEMAP_SIZE) {
                $batch->{count} = $batch->{count} + $raw_batch->{count};
                push @{$batch->{batches}}, $raw_batch->{batch};
            } else {
                push @batches, $batch;
                $batch = {count => $raw_batch->{count}, batches => [$raw_batch->{batch}]};
            }
        }
        push @batches, $batch;
    }

    # Add last batch.
    my $last_batch = $raw_batches->[scalar @$raw_batches - 1];
    push @batches, {count => $last_batch->{count},
                    batches => [$last_batch->{batch}]};

    for my $batch_info (@batches) {
        $self->build_one_batch($c, $entity_type, $batch_info);
    }
}

sub construct_url_lists($$$@) {
    my ($self, $c, $entity_type, $ids, %suffix_info) = @_;

    my @base_urls;
    my @paginated_urls;

    for my $id_info (@$ids) {
        my $id = $id_info->{main_id};
        my $url = $self->build_page_url($entity_type, $id, %suffix_info);

        push @base_urls, $self->create_url_opts($c, $entity_type, $url, \%suffix_info, $id_info);

        if ($suffix_info{paginated}) {
            # 100 items per page, and the first page is covered by the base.
            my $paginated_count = ceil($id_info->{$suffix_info{paginated}} / 100) - 1;

            # Since we exclude page 1 above, this is for anything above 0.
            if ($paginated_count > 0) {
                # Start from page 2, and add one to the count for the last page
                # (since the count was one less due to the exclusion of the first
                # page)
                my $use_amp = $url =~ m/\?/;
                my @new_paginated_urls = map { $url . ($use_amp ? '&' : '?') . "page=$_" } (2..$paginated_count+1);

                # Expand these all to full specifications for build_one_sitemap.
                push @paginated_urls, map {
                    $self->create_url_opts($c, $entity_type, $_, \%suffix_info, $id_info);
                } @new_paginated_urls;
            }
        }
    }

    return {base => \@base_urls, paginated => \@paginated_urls}
}

=head2 build_one_batch

Called by C<build_one_entity> for a given batch. Fetches the set of base URLs
and then builds the main sitemaps and any suffix sitemaps.

=cut

sub build_one_batch {
    my ($self, $c, $entity_type, $batch_info) = @_;

    my $entity_suffix_info = $SITEMAP_SUFFIX_INFO{$entity_type};
    my $minimum_batch_number = min(@{ $batch_info->{batches} });
    my $entity_id = $entity_type eq 'cdtoc' ? 'discid' : 'gid';

    # Merge the extra joins/columns needed for particular suffixes
    my %extra_sql = (join => '', columns => []);
    for my $suffix (keys %{$entity_suffix_info}) {
        my %extra = %{$entity_suffix_info->{$suffix}{extra_sql} // {}};
        if ($extra{columns}) {
            push(@{ $extra_sql{columns} }, $extra{columns});
        }
        if ($extra{join}) {
            $extra_sql{join} .= " JOIN $extra{join}";
        }
    }
    my $columns = join(', ', "$entity_id AS main_id", @{ $extra_sql{columns} });
    my $tables = $entity_type . $extra_sql{join};
    my $query = "SELECT $columns FROM $tables WHERE ceil($entity_type.id / ?::float) = any(?)";
    my $ids = $c->sql->select_list_of_hashes($query, $MAX_SITEMAP_SIZE, $batch_info->{batches});

    for my $suffix (sort keys %{$entity_suffix_info}) {
        my %suffix_info = %{$entity_suffix_info->{$suffix}};
        my $url_constructor = $suffix_info{url_constructor} // \&construct_url_lists;
        my $urls = $url_constructor->($self, $c, $entity_type, $ids, %suffix_info);

        $self->build_one_suffix($entity_type, $minimum_batch_number, $urls, %suffix_info);
    }
}

around do_not_delete => sub {
    my ($orig, $self, $file) = @_;

    # Do not delete incremental sitemap files.
    $self->$orig($file) || ($file =~ /incremental/);
};

sub run {
    my ($self) = @_;

    log('Building sitemaps and sitemap index files');

    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $self->database,
        fresh_connector => 1,
    );
    my $sql = $c->sql;

    my $sitemaps_control_exists = $sql->select_single_value(
        'SELECT 1 FROM sitemaps.control',
    );

    unless ($sitemaps_control_exists) {
        $sql->auto_commit(1);
        $sql->do('INSERT INTO sitemaps.control VALUES (NULL, NULL, TRUE)');
    }

    # Build sitemaps by looping over each entity type that's applicable and
    # calling `build_one_entity`. Runs in one repeatable-read transaction for
    # data consistency. Temporary tables are created and filled first.

    $self->drop_temporary_tables($sql); # Drop first, just in case.
    $self->create_temporary_tables($sql);

    $sql->begin;
    $sql->do("SET TRANSACTION READ ONLY, ISOLATION LEVEL REPEATABLE READ");
    $self->fill_temporary_tables($sql);
    for my $entity_type (entities_with(['mbid', 'indexable']), 'cdtoc') {
        $self->build_one_entity($c, $entity_type);
    }
    $sql->commit;
    $self->drop_temporary_tables($sql);

    # Once all sitemaps are built, write a sitemap index file.
    $self->write_index;

    # Update the `overall_sitemaps_replication_sequence` column in table
    # `sitemaps.control` so that the incremental sitemap builds know what
    # changes to include.
    $sql->auto_commit(1);
    $sql->do(<<'EOSQL');
UPDATE sitemaps.control
   SET overall_sitemaps_replication_sequence = last_processed_replication_sequence
EOSQL

    # Finally, ping search engines (if the option is turned on) and finish.
    $self->ping_search_engines($c);
    log('Done');
    return 0;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
