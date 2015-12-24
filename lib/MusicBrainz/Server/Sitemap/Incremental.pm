package MusicBrainz::Server::Sitemap::Incremental;

use strict;
use warnings;

use feature 'state';

use Data::Compare qw( Compare );
use Digest::SHA qw( sha1_hex );
use File::Path qw( rmtree );
use File::Slurp qw( read_file );
use File::Temp qw( tempdir );
use HTTP::Status qw( RC_OK RC_NOT_MODIFIED );
use JSON qw( decode_json );
use List::AllUtils qw( any );
use List::UtilsBy qw( partition_by );
use Memoize;
use Moose;
use Parallel::ForkManager 0.7.6;
use Sql;

use MusicBrainz::Server::Constants qw( entities_with );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::dbmirror;
use MusicBrainz::Server::Sitemap::Constants qw( %SITEMAP_SUFFIX_INFO );
use MusicBrainz::Server::Sitemap::Builder;
use MusicBrainz::Server::Sitemap::Utils qw( log );
use MusicBrainz::Server::Replication qw(
    retrieve_remote_file
    decompress_packet
);

extends 'MusicBrainz::Server::Sitemap::Builder';

with 'MooseX::Runnable';

=head1 SYNOPSIS

Backend for admin/BuildIncrementalSitemaps.pl.

This script works by:

    (1) Reading in the most recent replication packets. The last one that was
        processed is stored in the sitemaps.control table.

    (2) Iterating through every changed row.

    (3) Finding links (foreign keys) from each row to a core entity that we
        care about. We care about entities that have JSON-LD markup on their
        pages; these are indicated by the `sitemaps_lastmod_table` property
        inside the %ENTITIES hash.

        The foreign keys can be indirect (going through multiple tables). As an
        optimization, we do skip certain links that don't give meaningful
        connections (e.g. certain tables, and specific links on certain tables,
        don't ever affect the JSON-LD output of a linked entity).

    (4) Building a list of URLs for each linked entity we found. The URLs we
        care about are ones which are contained in the overall sitemaps, and
        which also contain embedded JSON-LD markup.

        Some URLs match only one (or neither) of these conditions, and are
        ignored. For example, we include JSON-LD on area pages, but don't build
        sitemaps for areas. Conversely, there are lots of URLs contained in the
        overall sitemaps which don't contain any JSON-LD markup.

    (5) Doing all of the above as quickly as possible, fast enough that this
        script can be run hourly.

=cut

my %INDEXABLE_ENTITIES = map { $_ => 1 } entities_with(['mbid', 'indexable']);
my @LASTMOD_ENTITIES = grep { exists $INDEXABLE_ENTITIES{$_} }
                       entities_with('sitemaps_lastmod_table');
my %LASTMOD_ENTITIES = map { $_ => 1 } @LASTMOD_ENTITIES;

my $pm = Parallel::ForkManager->new(2);

memoize('get_primary_keys');
memoize('get_foreign_keys');

BEGIN {
    if ($ENV{MUSICBRAINZ_RUNNING_TESTS}) {
        use Catalyst::Test 'MusicBrainz::Server';
        use HTTP::Headers;
        use HTTP::Request;

        *make_jsonld_request = sub {
            my ($c, $url) = @_;

            request(HTTP::Request->new(
                GET => $url,
                HTTP::Headers->new(Accept => 'application/ld+json'),
            ));
        };
    } else {
        *make_jsonld_request = sub {
            my ($c, $url) = @_;

            $c->lwp->get($url, Accept => 'application/ld+json');
        };
    }
}

sub build_and_check_urls($$$$$) {
    my ($self, $c, $pk_schema, $pk_table, $update, $joins) = @_;

    # Returns whether we found any changes to JSON-LD markup (a page was
    # added, or an existing page's markup changed.)
    my $found_changes = 0;

    my $fetch = sub {
        my ($row_id, $url, $is_paginated, $sitemap_suffix_key) = @_;

        my $was_updated = $self->fetch_and_handle_jsonld(
            $c,
            $pk_table,
            $row_id,
            $url,
            $update,
            $is_paginated,
            $sitemap_suffix_key,
        );

        if ($was_updated) {
            $found_changes = 1;
        }

        return $was_updated;
    };

    my $suffix_info = $SITEMAP_SUFFIX_INFO{$pk_table};
    my $entity_rows = $self->get_linked_entities($c, $pk_table, $update, $joins);

    unless (@{$entity_rows}) {
        log('No new entities found for sequence ID ' .
            $update->{sequence_id} . " in table $pk_table");
        return 0;
    }

    for my $suffix_key (sort keys %{$suffix_info}) {
        my $opts = $suffix_info->{$suffix_key};

        next unless $opts->{jsonld_markup};

        my $current = 0;
        my $remaining = @{$entity_rows};

        for my $row (@{$entity_rows}) {
            $current++;
            $remaining--;

            my $url = $self->build_page_url($pk_table, $row->{gid}, %{$opts});
            my $was_updated = $fetch->($row->{id}, $url, 0, $suffix_key);

            my $is_first_of_many = ($current == 0 && $remaining > 0);
            if ($is_first_of_many && !$was_updated) {
                log("Skipping $remaining");
                last;
            }

            if ($opts->{paginated}) {
                my $page = 2;

                # FIXME We should probably build URLs using the URI module.
                # But this is what BuildSitemaps.pl does.
                my $use_amp = $url =~ m/\?/;

                while ($was_updated) {
                    my $paginated_url = $url . ($use_amp ? '&' : '?') . "page=$page";

                    $was_updated = $fetch->($row->{id}, $paginated_url, 1, $suffix_key);
                }

            }
        }
    }

    return $found_changes;
}

# Declaration silences "called too early to check prototype" from recursive call.
sub fetch_and_handle_jsonld($$$$$$$);

sub fetch_and_handle_jsonld($$$$$$$) {
    my ($self, $c, $entity_type, $row_id, $url, $update, $is_paginated, $suffix_key) = @_;

    state $attempts = {};
    state $canonical_json = JSON->new->canonical->utf8;

    my $web_server = DBDefs->WEB_SERVER;
    my $canonical_server = DBDefs->CANONICAL_SERVER;
    my $request_url = $url;
    $request_url =~ s{\Q$canonical_server\E}{http://$web_server};

    my $response = make_jsonld_request($c, $request_url);

    # Responses should never redirect. If they do, we likely requested a page
    # number that doesn't exist.
    if ($response->previous) {
        log("Got redirect fetching $request_url, skipping");
        return 0;
    }

    if ($response->is_success) {
        my $new_hash = sha1_hex($canonical_json->encode(decode_json($response->content)));
        my ($operation, $last_modified, $replication_sequence) =
            @{$update}{qw(operation last_modified replication_sequence)};

        return Sql::run_in_transaction(sub {
            my $old_hash = $c->sql->select_single_value(<<"EOSQL", $row_id, $url);
SELECT encode(jsonld_sha1, 'hex') FROM sitemaps.${entity_type}_lastmod WHERE id = ? AND url = ?
EOSQL

            if (defined $old_hash) {
                if ($old_hash ne $new_hash) {
                    log("Found change at $url");

                    $c->sql->do(<<"EOSQL", "\\x$new_hash", $last_modified, $replication_sequence, $row_id, $url);
UPDATE sitemaps.${entity_type}_lastmod
   SET jsonld_sha1 = ?, last_modified = ?, replication_sequence = ?
 WHERE id = ? AND url = ?
EOSQL
                    return 1;
                }
                log("No change at $url");
            } else {
                log("Inserting lastmod entry for $url");

                $c->sql->do(
                    qq{INSERT INTO sitemaps.${entity_type}_lastmod (
                        id,
                        url,
                        paginated,
                        sitemap_suffix_key,
                        jsonld_sha1,
                        last_modified,
                        replication_sequence
                    ) VALUES (?, ?, ?, ?, ?, ?, ?)},
                    $row_id,
                    $url,
                    $is_paginated,
                    $suffix_key,
                    "\\x$new_hash",
                    $last_modified,
                    $replication_sequence
                );

                # Indicate a "change" if this is a new entity.
                return 1 if (
                    $operation eq 'i' &&
                    get_ident($update) eq "musicbrainz.$entity_type.id" &&
                    $update->{value} == $row_id
                );
            }

            return 0;
        }, $c->sql);
    }

    my $code = $response->code;
    if ($code =~ /^5/) {
        if (!(defined $attempts->{$url}) || $attempts->{$url} < 3) {
            sleep 10;
            $attempts->{$url}++;
            return $self->fetch_and_handle_jsonld(
                $c,
                $entity_type,
                $row_id,
                $url,
                $update,
                $is_paginated,
                $suffix_key,
            );
        }
    }

    log("ERROR: Got response code $code fetching $request_url");
    return 0;
}

sub get_primary_keys($$$) {
    my ($self, $c, $schema, $table) = @_;

    map {
        # Some columns are wrapped in quotes, others aren't...
        $_ =~ s/^"(.*?)"$/$1/; $_
    } $c->sql->dbh->primary_key(undef, $schema, $table);
}

sub get_foreign_keys($$$$) {
    my ($self, $c, $direction, $schema, $table) = @_;

    my $foreign_keys = [];
    my ($sth, $all_keys);

    if ($direction == 1) {
        # Get FK columns in other tables that refer to PK columns in $table.
        $sth = $c->sql->dbh->foreign_key_info(undef, $schema, $table, (undef) x 3);
        if (defined $sth) {
            $all_keys = $sth->fetchall_arrayref;
        }
    } elsif ($direction == 2) {
        # Get FK columns in $table that refer to PK columns in other tables.
        $sth = $c->sql->dbh->foreign_key_info((undef) x 4, $schema, $table);
        if (defined $sth) {
            $all_keys = $sth->fetchall_arrayref;
        }
    }

    if (defined $all_keys) {
        for my $info (@{$all_keys}) {
            my ($pk_schema, $pk_table, $pk_column);
            my ($fk_schema, $fk_table, $fk_column);

            if ($direction == 1) {
                ($pk_schema, $pk_table, $pk_column) = @{$info}[1..3];
                ($fk_schema, $fk_table, $fk_column) = @{$info}[5..7];
            } elsif ($direction == 2) {
                ($fk_schema, $fk_table, $fk_column) = @{$info}[1..3];
                ($pk_schema, $pk_table, $pk_column) = @{$info}[5..7];
            }

            if ($schema eq $pk_schema && $table eq $pk_table) {
                push @{$foreign_keys}, {
                    pk_column => $pk_column,
                    fk_schema => $fk_schema,
                    fk_table => $fk_table,
                    fk_column => $fk_column,
                };
            }
        }
    }

    return $foreign_keys;
}

sub should_fetch_jsonld($$) {
    my ($schema, $table) = @_;

    return $schema eq 'musicbrainz' && exists $LASTMOD_ENTITIES{$table};
}

sub should_follow_table($) {
    my $table = shift;

    return 0 if $table eq 'cover_art_archive.cover_art_type';
    return 0 if $table eq 'musicbrainz.cdtoc';
    return 0 if $table eq 'musicbrainz.language';
    return 0 if $table eq 'musicbrainz.medium_cdtoc';
    return 0 if $table eq 'musicbrainz.medium_index';

    return 0 if $table =~ qr'[._](tag_|tag$)';
    return 0 if $table =~ qw'_(meta|raw|gid_redirect)$';

    return 1;
}

sub should_follow_primary_key($) {
    my $pk = shift;

    # Nothing in mbserver should update an artist_credit row on its own; we
    # treat them as immutable using a find_or_insert method. (It's possible
    # an upgrade script changed them, but that's unlikely.)
    return 0 if $pk eq 'musicbrainz.artist_credit.id';

    # Useless joins.
    return 0 if $pk eq 'musicbrainz.artist_credit_name.position';
    return 0 if $pk eq 'musicbrainz.release_country.country';
    return 0 if $pk eq 'musicbrainz.release_group_secondary_type_join.secondary_type';

    return 1;
}

sub get_ident($) {
    my $args = shift;

    return $args unless ref($args) eq 'HASH';

    my ($schema, $table, $column) = @{$args}{qw(schema table column)};
    return "$schema.$table.$column";
}

sub should_follow_foreign_key($$$) {
    my ($pk, $fk, $joins) = @_;

    return 0 if any {
        my ($lhs, $rhs) = @{$_}{qw(lhs rhs)};

        (ref($lhs) eq 'HASH' && Compare($lhs, $pk))
        ||
        (ref($rhs) eq 'HASH' && Compare($rhs, $fk))
    } @{$joins};

    $pk = get_ident($pk);
    $fk = get_ident($fk);

    # Modifications to a track shouldn't affect a recording's JSON-LD.
    return 0 if $pk eq 'musicbrainz.track.recording' && $fk eq 'musicbrainz.recording.id';

    return 1;
}

sub get_linked_entities($$$$) {
    my ($self, $c, $entity_type, $update, $joins) = @_;

    my ($src_schema, $src_table, $src_column, $src_value, $replication_sequence) =
        @{$update}{qw(schema table column value replication_sequence)};

    my $joins_string = join ' ', map {
        my ($lhs, $rhs) = @{$_}{qw(lhs rhs)};

        my ($schema, $table) = @{$lhs}{qw(schema table)};

        "JOIN $schema.$table ON " . get_ident($lhs) . ' = ' . get_ident($rhs);
    } @{$joins};

    my $table = "musicbrainz.$entity_type";

    Sql::run_in_transaction(sub {
        $c->sql->do('LOCK TABLE sitemaps.tmp_checked_entities IN SHARE ROW EXCLUSIVE MODE');

        my $entity_rows = $c->sql->select_list_of_hashes(
            "SELECT DISTINCT $table.id, $table.gid
               FROM $table
               $joins_string
              WHERE ($src_schema.$src_table.$src_column = $src_value)
                AND NOT EXISTS (
                    SELECT 1 FROM sitemaps.tmp_checked_entities ce
                     WHERE ce.entity_type = '$entity_type'
                       AND ce.id = $table.id
                )"
        );

        my @entity_rows = @{$entity_rows};
        if (@entity_rows) {
            $c->sql->do(
                'INSERT INTO sitemaps.tmp_checked_entities (id, entity_type) ' .
                'VALUES ' . (join ', ', ("(?, '$entity_type')") x scalar(@entity_rows)),
                map { $_->{id} } @entity_rows,
            );
        }

        $entity_rows;
    }, $c->sql);
}

# Declaration silences "called too early to check prototype" from recursive call.
sub find_entities_with_jsonld($$$$$$);
sub follow_foreign_keys($$$$$$);

sub find_entities_with_jsonld($$$$$$) {
    my $self = shift;

    my ($c, $direction, $pk_schema, $pk_table, $update, $joins) = @_;

    if (should_fetch_jsonld($pk_schema, $pk_table)) {
        $pm->start and return;

        # This should be refreshed for each new worker, as internal DBI handles
        # would otherwise be shared across processes (and are not advertized as
        # MPSAFE).
        my $new_c = MusicBrainz::Server::Context->create_script_context(
            database => $self->database,
            fresh_connector => 1,
        );
        my $any_updates = $self->build_and_check_urls($new_c, $pk_schema, $pk_table, $update, $joins);
        my $exit_code = $any_updates ? 0 : 1;
        my $shared_data;

        if ($any_updates) {
            my @args = @_;
            shift @args;
            $shared_data = \@args;
        }

        $new_c->connector->disconnect;
        $pm->finish($exit_code, $shared_data);
    } else {
        $self->follow_foreign_keys(@_);
    }
}

sub follow_foreign_keys($$$$$$) {
    my ($self, $c, $direction, $pk_schema, $pk_table, $update, $joins) = @_;

    # Continue traversing the schemas until we stop finding changes.
    my $foreign_keys = $self->get_foreign_keys($c, $direction, $pk_schema, $pk_table);
    return unless @{$foreign_keys};

    for my $info (@{$foreign_keys}) {
        my ($pk_column, $fk_schema, $fk_table, $fk_column) =
            @{$info}{qw(pk_column fk_schema fk_table fk_column)};

        my $lhs = {schema => $pk_schema, table => $pk_table, column => $pk_column};
        my $rhs = {schema => $fk_schema, table => $fk_table, column => $fk_column};

        next unless should_follow_foreign_key($lhs, $rhs, $joins);

        $self->find_entities_with_jsonld(
            $c,
            $direction,
            $fk_schema,
            $fk_table,
            $update,
            [{lhs => $lhs, rhs => $rhs}, @{$joins}],
        );
    }
}

sub handle_replication_sequence($$) {
    my ($self, $c, $sequence) = @_;

    my $file = "replication-$sequence.tar.bz2";
    my $url = $self->replication_access_uri . "/$file";
    my $local_file = "/tmp/$file";

    my $resp = retrieve_remote_file($url, $local_file);
    unless ($resp->code == RC_OK or $resp->code == RC_NOT_MODIFIED) {
        die $resp->as_string;
    }

    my $output_dir = decompress_packet(
        'sitemaps-XXXXXX',
        '/tmp',
        $local_file,
        1, # CLEANUP
    );

    my (%changes, %change_keys);
    open my $dbmirror_pending, '<', "$output_dir/mbdump/dbmirror_pending";
    while (<$dbmirror_pending>) {
        my ($seq_id, $table_name, $op) = split /\t/;

        my ($schema, $table) = map { m/"(.*?)"/; $1 } split /\./, $table_name;

        next unless should_follow_table("$schema.$table");

        $changes{$seq_id} = {
            schema      => $schema,
            table       => $table,
            operation   => $op,
        };
    }

    # Fallback for rows that don't have a last_updated column.
    my $last_updated_fallback = $c->sql->select_single_value('SELECT now()');

    # File::Slurp is required so that fork() doesn't interrupt IO.
    my @dbmirror_pendingdata = read_file("$output_dir/mbdump/dbmirror_pendingdata");
    for (@dbmirror_pendingdata) {
        my ($seq_id, $is_key, $data) = split /\t/;

        chomp $data;
        $data = MusicBrainz::Server::dbmirror::unpack_data($data, $seq_id);

        if ($is_key eq 't') {
            $change_keys{$seq_id} = $data;
            next;
        }

        # Undefined if the table was skipped, per should_follow_table.
        my $change = $changes{$seq_id};
        next unless defined $change;

        my $conditions = $change_keys{$seq_id} // {};
        my ($schema, $table) = @{$change}{qw(schema table)};

        my @primary_keys = grep {
            should_follow_primary_key("$schema.$table.$_")
        } $self->get_primary_keys($c, $schema, $table);

        for my $pk_column (@primary_keys) {
            my $pk_value = $c->sql->dbh->quote(
                $conditions->{$pk_column} // $data->{$pk_column},
                $c->sql->get_column_data_type("$schema.$table", $pk_column)
            );

            my $last_modified = $data->{last_updated};

            # Some tables have a `created` column. Use that as a fallback if
            # this is an insert.
            if (!(defined $last_modified) && $change->{operation} eq 'i') {
                $last_modified = $data->{created};
            }

            # Otherwise, use the current time.
            $last_modified //= $last_updated_fallback;

            my $update = {
                %{$change},
                sequence_id             => $seq_id,
                column                  => $pk_column,
                value                   => $pk_value,
                last_modified           => $last_modified,
                replication_sequence    => $sequence,
            };

            for (1...2) {
                $self->find_entities_with_jsonld($c, $_, $schema, $table, $update, []);
            }
        }
    }

    $pm->wait_all_children;

    log("Removing $output_dir");
    rmtree($output_dir);

    for my $entity_type (@LASTMOD_ENTITIES) {
        # The sitemaps.control columns will be NULL on first run, in which case
        # we just select all updates for writing.
        my $all_updates = $c->sql->select_list_of_hashes(
            "SELECT lm.*
               FROM sitemaps.${entity_type}_lastmod lm
              WHERE lm.replication_sequence > COALESCE(
                (SELECT overall_sitemaps_replication_sequence FROM sitemaps.control), 0)"
        );

        my %updates_by_suffix_key = partition_by {
            $_->{sitemap_suffix_key}
        } @{$all_updates};

        for my $suffix_key (sort keys %updates_by_suffix_key) {
            my $updates = $updates_by_suffix_key{$suffix_key};

            my (@base_urls, @paginated_urls);
            my $urls = {base => \@base_urls, paginated => \@paginated_urls};
            my $suffix_info = $SITEMAP_SUFFIX_INFO{$entity_type}{$suffix_key};

            for my $update (@{$updates}) {
                my $opts = $self->create_url_opts(
                    $c,
                    $entity_type,
                    $update->{url},
                    $suffix_info,
                    {last_modified => $update->{last_modified}},
                );

                if ($update->{paginated}) {
                    push @paginated_urls, $opts;
                } else {
                    push @base_urls, $opts;
                }
            }

            my %opts = %{$suffix_info};
            my $filename_suffix = $opts{filename_suffix} // $opts{suffix};

            if ($filename_suffix) {
                $opts{filename_suffix} = "$filename_suffix-incremental";
            } else {
                $opts{filename_suffix} = 'incremental';
            }

            $self->build_one_suffix($entity_type, 1, $urls, %opts);
        }
    }
}

around do_not_delete => sub {
    my ($orig, $self, $file) = @_;

    # Do not delete overall sitemap files.
    $self->$orig($file) || ($file !~ /incremental/);
};

sub get_current_replication_sequence {
    my ($self, $c) = @_;

    my $replication_info_uri = $self->replication_access_uri . '/replication-info';
    my $response = $c->lwp->get("$replication_info_uri?token=" . DBDefs->REPLICATION_ACCESS_TOKEN);

    unless ($response->code == 200) {
        log("ERROR: Request to $replication_info_uri returned status code " . $response->code);
        exit 1;
    }

    my $replication_info = decode_json($response->content);
    my $current_seq = $replication_info->{last_packet};
    $current_seq =~ s/^replication-([0-9]+)\.tar\.bz2$/$1/;
    return $current_seq;
}

sub run {
    my ($self) = @_;

    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $self->database,
        fresh_connector => 1,
    );

    $pm->run_on_finish(sub {
        my $shared_data = pop;

        my ($pid, $exit_code) = @_;

        if ($exit_code == 0) {
            $self->follow_foreign_keys($c, @{$shared_data});
        }
    });

    my $sitemaps_control = $c->sql->select_single_value(
        'SELECT 1 FROM sitemaps.control'
    );

    unless (defined $sitemaps_control) {
        log("ERROR: Table sitemaps.control is empty (has admin/BuildSitemaps.pl run yet?)");
        exit 1;
    }

    unless (-f $self->index_localname) {
        log("ERROR: No sitemap index file was found");
        exit 1;
    }

    my $last_processed_seq = $c->sql->select_single_value(
        'SELECT last_processed_replication_sequence FROM sitemaps.control'
    );
    my $should_update_index = 0;

    while (1) {
        my $current_seq = $self->get_current_replication_sequence($c);

        if (defined $last_processed_seq) {
            if ($current_seq == $last_processed_seq) {
                log("Up-to-date.");
                last;
            }
        } else {
            $last_processed_seq = $current_seq - 1;
        }

        if ($should_update_index == 0) { # only executed on first iteration
            my $checked_entities = $c->sql->select_single_value(
                'SELECT 1 FROM sitemaps.tmp_checked_entities'
            );

            # If sitemaps.tmp_checked_entities is not empty, then another copy
            # of the script is either still running (perhaps because it has to
            # process a large number of changes), or has crashed unexpectedly
            # (if it had completed normally, then the table would have been
            # truncated below).

            if ($checked_entities) {
                # Don't generate cron email spam until we're more behind than
                # usual, since that could indicate a problem.

                if (($current_seq - $last_processed_seq) > 2) {
                    log("ERROR: Table sitemaps.tmp_checked_entities is not " .
                        "empty, and the script is more than two replication " .
                        "packets behind. You should check that a previous " .
                        "run of the script didn't unexpectedly die; this " .
                        "script will not run again until " .
                        "sitemaps.tmp_checked_entities is cleared.");
                    exit 1;
                }
                exit 0;
            }
        }

        $self->handle_replication_sequence($c, ++$last_processed_seq);

        $c->sql->auto_commit(1);
        $c->sql->do('TRUNCATE sitemaps.tmp_checked_entities');

        $c->sql->auto_commit(1);
        $c->sql->do(
            'UPDATE sitemaps.control SET last_processed_replication_sequence = ?',
            $last_processed_seq,
        );

        $should_update_index = 1;
    }

    if ($should_update_index) {
        $self->write_index;
        $self->ping_search_engines($c);
    }
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
