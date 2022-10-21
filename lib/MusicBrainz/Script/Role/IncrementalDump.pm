package MusicBrainz::Script::Role::IncrementalDump;

use strict;
use warnings;

use Data::Dumper;
use DBDefs;
use File::Path qw( rmtree );
use File::Slurp qw( read_file );
use HTTP::Status qw( RC_OK RC_NOT_MODIFIED );
use JSON qw( decode_json );
use Moose::Role;
use MusicBrainz::Script::Utils qw( get_primary_keys retry );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::dbmirror;
use MusicBrainz::Server::Log qw( log_info );
use MusicBrainz::Server::Replication qw( REPLICATION_ACCESS_URI );
use MusicBrainz::Server::Replication::Packet qw(
    decompress_packet
    retrieve_remote_file
);
use Sql;

with 'MusicBrainz::Server::Role::FollowForeignKeys';

requires qw(
    database
    dump_schema
    dumped_entity_types
    get_changed_documents
    handle_update_path
    post_replication_sequence
    pre_key_traversal
    should_follow_table
);

=head1 SYNOPSIS

Backend for admin/BuildIncrementalSitemaps.pl and admin/DumpJSON.

This script works by:

    (1) Reading in the most recent replication packets. The last one that was
        processed is stored in the $schema.control table.

    (2) Iterating through every changed row.

    (3) Finding links (foreign keys) from each row to a core entity that we
        care about.

        (For BuildIncrementalSitemaps, we care about entities that have
        JSON-LD markup on their pages; these are indicated by the
        `sitemaps_lastmod_table` property inside the %ENTITIES hash.)

        The foreign keys can be indirect (going through multiple tables). As an
        optimization, we do skip certain links that don't give meaningful
        connections (e.g. certain tables, and specific links on certain tables,
        don't ever affect the JSON-LD output of a linked entity).

    (4) Building a list of URLs for each linked entity we found.

        For sitemaps, the URLs we care about are ones which are contained in
        the overall sitemaps, and which also contain embedded JSON-LD markup.

        Some URLs match only one (or neither) of these conditions, and are
        ignored. For example, we include JSON-LD on area pages, but don't build
        sitemaps for areas. Conversely, there are lots of URLs contained in the
        overall sitemaps which don't contain any JSON-LD markup.

        For the JSON dumps, we care about most URLs, except for 'url' and
        standalone recording ones.

    (5) Doing all of the above as quickly as possible, fast enough that this
        script can be run hourly.

=cut

has replication_access_uri => (
    is => 'ro',
    isa => 'Str',
    default => REPLICATION_ACCESS_URI,
    traits => ['Getopt'],
    cmd_flag => 'replication-access-uri',
    documentation => 'URI to request replication packets from (default: https://metabrainz.org/api/musicbrainz)',
);

has packet_limit => (
    is => 'rw',
    isa => 'Int',
    default => 0,
    traits => ['Getopt'],
    cmd_flag => 'packet-limit',
    documentation => ('process only this many packets, ' .
                      'or specify 0 to process all (default: 0)'),
);

our $parent_pid;
our $saved_database;
our $saved_dump_schema;

BEGIN {
    $parent_pid = $$;
}

END {
    return unless ($$ == $parent_pid &&
                   $saved_database &&
                   $saved_dump_schema);

    log_info { "Truncating $saved_dump_schema.tmp_checked_entities" };
    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $saved_database,
        fresh_connector => 1,
    );
    $c->sql->auto_commit(1);
    $c->sql->do("TRUNCATE $saved_dump_schema.tmp_checked_entities");
    $c->connector->disconnect;
}

sub should_fetch_document($$) {
    my ($self, $schema, $table) = @_;

    return $schema eq 'musicbrainz' &&
        (grep { $_ eq $table } @{ $self->dumped_entity_types });
}

sub should_follow_primary_key($) {
    my $pk = shift;

    # Tag tables currently generate too many updates to process
    # efficiently.
    return 0 if $pk eq 'musicbrainz.tag.id';
    return 0 if $pk =~ /_tag/;

    # Nothing in mbserver should update an artist_credit row on its own; we
    # treat them as immutable using a find_or_insert method. (It's possible
    # an upgrade script changed them, but that's unlikely.)
    return 0 if $pk eq 'musicbrainz.artist_credit.id';

    # Useless joins.
    return 0 if $pk eq 'cover_art_archive.cover_art_type.type_id';
    return 0 if $pk eq 'event_art_archive.event_art_type.type_id';
    return 0 if $pk eq 'musicbrainz.artist_credit_name.position';
    return 0 if $pk eq 'musicbrainz.release_country.country';
    return 0 if $pk eq 'musicbrainz.release_group_secondary_type_join.secondary_type';
    return 0 if $pk eq 'musicbrainz.work_language.language';
    return 0 if $pk eq 'musicbrainz.medium.format';

    return 1;
}

around should_follow_foreign_key => sub {
    my ($orig, $self, $direction, $pk, $fk, $joins) = @_;

    return 0 unless $self->$orig($direction, $pk, $fk, $joins);

    return 0 unless $self->should_follow_table($fk->{schema} . q(.) . $fk->{table});

    return 0 if $self->has_join($pk, $fk, $joins);

    $pk = get_ident($pk);
    $fk = get_ident($fk);

    # Modifications to a release_country don't affect the country (area).
    return 0 if (
        $pk eq 'musicbrainz.release_country.country' &&
        $fk eq 'musicbrainz.country_area.area'
    );

    # Modifications to a release_label don't affect the label.
    return 0 if $pk eq 'musicbrainz.release_label.label' && $fk eq 'musicbrainz.label.id';

    # Modifications to a track shouldn't affect a recording's JSON-LD.
    return 0 if $pk eq 'musicbrainz.track.recording' && $fk eq 'musicbrainz.recording.id';

    # Modifications to artist credits don't affect the linked artists.
    if ($fk eq 'musicbrainz.artist_credit.id') {
        return 0 if $pk eq 'musicbrainz.alternative_release.artist_credit';
        return 0 if $pk eq 'musicbrainz.alternative_track.artist_credit';
        return 0 if $pk eq 'musicbrainz.recording.artist_credit';
        return 0 if $pk eq 'musicbrainz.release.artist_credit';
        return 0 if $pk eq 'musicbrainz.release_group.artist_credit';
        return 0 if $pk eq 'musicbrainz.track.artist_credit';
    }

    return 1;
};

# Declaration silences "called too early to check prototype" from recursive call.
sub follow_primary_key($$$$$$);

sub follow_primary_key($$$$$$) {
    my $self = shift;

    my ($c, $direction, $pk_schema, $pk_table, $update, $joins) = @_;

    if ($self->should_fetch_document($pk_schema, $pk_table)) {
        my $total_changed = 0;
        my $fetch_document = sub {
            my ($item, %extra_args) = @_;

            # What $item is is up to the consumer of this role and
            # its implementation of get_changed_documents. For
            # sitemaps, it's a single row; for the json dumps, it's
            # an array of row IDs.
            my $changed = $self->get_changed_documents(
                $c, $pk_table, $item, $update, %extra_args);
            $total_changed += $changed;
            return $changed;
        };

        my $entity_rows = $self->get_linked_entities(
            $c, $pk_table, $update, $joins);

        if (@{$entity_rows}) {
            $self->handle_update_path(
                $c, $pk_table, $entity_rows, $fetch_document);
            return $total_changed;
        } else {
            log_info {'No more linked entities found for sequence ID ' .
                      $update->{sequence_id} . " in table $pk_table" };
            return 0;
        }
    }

    return 1;
}

sub get_linked_entities($$$$) {
    my ($self, $c, $entity_type, $update, $joins) = @_;

    my $dump_schema = $self->dump_schema;

    my ($src_schema, $src_table, $src_column, $src_value) =
        @{$update}{qw(schema table column value)};

    my $first_join;
    my $last_join;

    if (@$joins) {
        $first_join = $joins->[0];
        $last_join = $joins->[scalar(@$joins) - 1];

        # The target entity table we're selecting from should always be the
        # RHS of the first join. Conversely, the source table - i.e., where
        # the change originated - should always be the LHS of the final join.
        # These values are still passed through via @_ and $update, because
        # there sometimes aren't any joins. In that case, the source and
        # target tables should be equal.
        die ('Bad join: ' . Dumper($joins)) unless (
            $first_join->{rhs}{schema} eq 'musicbrainz' &&
            $first_join->{rhs}{table}  eq $entity_type  &&

            $last_join->{lhs}{schema}  eq $src_schema   &&
            $last_join->{lhs}{table}   eq $src_table
        );
    } else {
        die 'Bad join' unless (
            $src_schema eq 'musicbrainz' &&
            $src_table  eq $entity_type
        );
    }

    my $table = "musicbrainz.$entity_type";
    my $joins_string = '';
    my $src_alias;

    if (@$joins) {
        my $aliases = {
            $table => 'entity_table',
        };
        $joins_string = stringify_joins($joins, $aliases);
        $src_alias = $aliases->{"$src_schema.$src_table"};
    } else {
        $src_alias = 'entity_table';
    }

    my $tx = sub {
        $c->sql->do("LOCK TABLE $dump_schema.tmp_checked_entities IN SHARE ROW EXCLUSIVE MODE");

        my $entity_rows = $c->sql->select_list_of_hashes(
            "SELECT DISTINCT entity_table.id, entity_table.gid
               FROM $table entity_table
               $joins_string
              WHERE ($src_alias.$src_column = $src_value)
                AND NOT EXISTS (
                    SELECT 1 FROM $dump_schema.tmp_checked_entities ce
                     WHERE ce.entity_type = '$entity_type'
                       AND ce.id = entity_table.id
                )"
        );

        my @entity_rows = @{$entity_rows};
        if (@entity_rows) {
            $c->sql->do(
                "INSERT INTO $dump_schema.tmp_checked_entities (id, entity_type) " .
                'VALUES ' . (join q(, ), ("(?, '$entity_type')") x scalar(@entity_rows)),
                map { $_->{id} } @entity_rows,
            );
        }

        $entity_rows;
    };

    my $rows = retry(
        sub { Sql::run_in_transaction($tx, $c->sql) },
        reason => 'getting linked entities',
    );
    return $rows;
}

sub handle_replication_sequence($$) {
    my ($self, $c, $sequence) = @_;

    my $dump_schema = $self->dump_schema;
    my $file = "replication-$sequence.tar.bz2";
    my $url = $self->replication_access_uri . "/$file";
    my $local_file = "/tmp/$file";

    my $resp = retrieve_remote_file($url, $local_file);
    unless ($resp->code == RC_OK or $resp->code == RC_NOT_MODIFIED) {
        die $resp->as_string;
    }

    my $output_dir = decompress_packet(
        "$dump_schema-XXXXXX",
        '/tmp',
        $local_file,
        1, # CLEANUP
    );

    my (%changes, %change_keys);
    open my $dbmirror_pending, '<', "$output_dir/mbdump/dbmirror_pending";
    while (<$dbmirror_pending>) {
        my $line = $_;

        next if $line =~ /^\s*$/;

        my ($seq_id, $table_name, $op) = split /\t/, $line;

        my ($schema, $table) = map { m/"(.*?)"/; $1 } split /\./, $table_name;

        next unless $self->should_follow_table("$schema.$table");

        $changes{$seq_id} = {
            schema      => $schema,
            table       => $table,
            operation   => $op,
        };
    }

    # File::Slurp is required so that fork() doesn't interrupt IO.
    my @dbmirror_pendingdata = read_file("$output_dir/mbdump/dbmirror_pendingdata");
    for (@dbmirror_pendingdata) {
        my $line = $_;

        next if $line =~ /^\s*$/;

        my ($seq_id, $is_key, $data) = split /\t/, $line;

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
        my $last_modified = $data->{last_updated};

        # Some tables have a `created` column. Use that as a fallback if
        # this is an insert.
        if (!(defined $last_modified) && $change->{operation} eq 'i') {
            $last_modified = $data->{created};
        }

        $self->pre_key_traversal(
            $c, $change, $data, $sequence, $last_modified);

        my @primary_keys = grep {
            should_follow_primary_key("$schema.$table.$_")
        } get_primary_keys($c, $schema, $table);

        for my $pk_column (@primary_keys) {
            my $value = $conditions->{$pk_column} // $data->{$pk_column};
            # retry: transient "Can't use an undefined value as an ARRAY
            # reference" errors have happened in DBD::Pg::db::column_info.
            my $data_type = retry(
                sub { $c->sql->get_column_data_type("$schema.$table", $pk_column) },
                reason => 'getting column data type',
            );
            # retry: transient "No such database: musicbrainz_json_dump"
            # errors have happened here.
            my $pk_value = retry(
                sub { $c->sql->dbh->quote($value, $data_type) },
                reason => 'quoting value',
            );

            my $update = {
                %{$change},
                sequence_id             => $seq_id,
                column                  => $pk_column,
                value                   => $pk_value,
                last_modified           => $last_modified,
                replication_sequence    => $sequence,
            };

            for (1...2) {
                my @args = ($c, $_, $schema, $table, $update, []);
                if ($self->follow_primary_key(@args)) {
                    $self->follow_foreign_keys(@args);
                }
            }
        }
    }

    log_info { "Removing $output_dir" };
    rmtree($output_dir);

    $self->post_replication_sequence($c);
}

sub get_current_replication_sequence {
    my ($self, $c) = @_;

    my $replication_info_uri = $self->replication_access_uri . '/replication-info';
    my $response = $c->lwp->get("$replication_info_uri?token=" . DBDefs->REPLICATION_ACCESS_TOKEN);

    unless ($response->code == 200) {
        log_info { "ERROR: Request to $replication_info_uri returned status code " . $response->code };
        exit 1;
    }

    my $replication_info = decode_json($response->content);

    $replication_info->{last_packet} =~ s/^replication-([0-9]+)\.tar\.bz2$/$1/r
}

sub run_incremental_dump {
    my ($self, $c, $replication_sequence) = @_;

    my $dump_schema = $self->dump_schema;

    # Needed in the END block at the top of the file which handles clearing
    # tmp_checked_entities.
    $saved_database = $self->database;
    $saved_dump_schema = $dump_schema;

    my $control_is_empty = !$c->sql->select_single_value(
        "SELECT 1 FROM $dump_schema.control"
    );

    if ($control_is_empty) {
        log_info { "ERROR: Table $dump_schema.control is empty (has a full dump run yet?)" };
        exit 1;
    }

    my $last_processed_seq = $c->sql->select_single_value(
        "SELECT last_processed_replication_sequence FROM $dump_schema.control"
    );
    my $did_update_anything = 0;
    my $packets_processed = 0;

    while (1) {
        my $current_seq = $self->get_current_replication_sequence($c);

        if (defined $last_processed_seq) {
            if ($current_seq == $last_processed_seq) {
                log_info { 'Up-to-date.' };
                last;
            }
        } else {
            $last_processed_seq = $current_seq - 1;
        }

        $replication_sequence //= ($last_processed_seq + 1);

        if ($did_update_anything == 0) { # only executed on first iteration
            my $checked_entities = $c->sql->select_single_value(
                "SELECT 1 FROM $dump_schema.tmp_checked_entities"
            );

            # If $dump_schema.tmp_checked_entities is not empty, then another
            # copy of the script is either still running (perhaps because it
            # has to process a large number of changes), or has crashed
            # unexpectedly (if it had completed normally, then the table
            # would have been truncated below).

            if ($checked_entities) {
                # Don't generate cron email spam until we're more behind than
                # usual, since that could indicate a problem.

                if (($current_seq - $last_processed_seq) > 2) {
                    log_info { "ERROR: Table $dump_schema.tmp_checked_entities " .
                               'is not empty, and the script is more than two ' .
                               'replication packets behind. You should check ' .
                               q(that a previous run of the script didn't ) .
                               'unexpectedly die; this script will not run again ' .
                               "until $dump_schema.tmp_checked_entities is " .
                               'cleared.' };
                    exit 1;
                }
                exit 0;
            }
        }

        $self->handle_replication_sequence($c, $replication_sequence);

        $c->sql->auto_commit(1);
        $c->sql->do("TRUNCATE $dump_schema.tmp_checked_entities");

        $c->sql->auto_commit(1);
        $c->sql->do(
            "UPDATE $dump_schema.control SET last_processed_replication_sequence = ?",
            $replication_sequence,
        );

        $did_update_anything = 1;
        $packets_processed++;
        $last_processed_seq = $replication_sequence++;

        my $packet_limit = $self->packet_limit;
        if ($packet_limit > 0 && $packets_processed == $packet_limit) {
            last;
        }
    }

    return $did_update_anything;
}

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
