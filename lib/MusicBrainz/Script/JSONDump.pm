package MusicBrainz::Script::JSONDump;

use strict;
use warnings;
use feature 'state';

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory';
use Data::Dumper;
use DBDefs;
use English;
use File::Copy qw( move );
use File::Path qw( rmtree );
use File::Spec::Functions qw( catdir catfile tmpdir );
use File::Temp qw( tempdir );
use Fcntl qw( :flock );
use JSON::XS;
use List::AllUtils qw( natatime );
use Moose;
use MusicBrainz::Script::JSONDump::Constants qw( %DUMPED_ENTITY_TYPES );
use MusicBrainz::Script::MBDump;
use MusicBrainz::Script::Utils qw( retry );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::JSONLookup qw( json_lookup );
use MusicBrainz::Server::Log qw( log_info );
use Readonly;

with 'MooseX::Getopt';

has c => (
    handles => ['sql', 'dbh'],
    is => 'rw',
    isa => 'MusicBrainz::Server::Context',
    traits => ['NoGetopt'],
);

has compression_enabled => (
    is => 'ro',
    isa => 'Bool',
    default => 1,
    traits => ['Getopt'],
    cmd_flag => 'compress',
    documentation => 'compress with xz (default: enabled)',
);

has database => (
    is => 'ro',
    isa => 'Str',
    default => 'MAINTENANCE',
    traits => ['Getopt'],
    documentation => 'database to use (default: MAINTENANCE)',
);

has dumped_entity_types => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub { [sort { $a cmp $b } keys %DUMPED_ENTITY_TYPES] },
    traits => ['Array', 'Getopt'],
    cmd_flag => 'entity',
    documentation => ('entity to dump; can specify multiple of this flag ' .
                      '(default: dump all entities)'),
);

has output_dir => (
    is => 'ro',
    isa => 'Str',
    default => q(.),
    traits => ['Getopt'],
    cmd_flag => 'output-dir',
    documentation => 'location where dumps are outputted (default: .)',
);

with 'MusicBrainz::Script::Role::TestCacheNamespace';

our $TMP_EXPORT_DIR = tempdir(
    'json-dump-XXXXXX',
    DIR => tmpdir(),
    CLEANUP => 0,
);

Readonly our $BATCH_SIZE => 100;

sub create_json_dump {
    my ($self, $c, $table_name, %mbdump_options) = @_;

    my $dump_fname = $ENTITIES{$table_name}{url};
    my $dump_fpath = catfile($TMP_EXPORT_DIR, $dump_fname);

    return unless -s $dump_fpath;

    local $MusicBrainz::Script::MBDump::readme_text = <<'EOF';
The file under mbdump/ contains one document (entity) per line, in JSON
format, and is named according to the type of entity in the dump.
EOF

    my $mbdump = MusicBrainz::Script::MBDump->new(
        c => $c,
        compression => 'xz',
        output_dir => $self->output_dir,
        %mbdump_options,
    );

    $mbdump->copy_file(
        catfile(DBDefs->MB_SERVER_ROOT, 'admin', 'COPYING-PublicDomain'),
        'COPYING'
    ) or die $OS_ERROR;

    $mbdump->write_file('JSON_DUMPS_SCHEMA_NUMBER', "1\n");

    my $dest_dump_fpath = catfile(
        $mbdump->export_dir, 'mbdump', $dump_fname);
    move($dump_fpath, $dest_dump_fpath) or die $OS_ERROR;

    if ($self->compression_enabled) {
        $mbdump->make_tar(
            "$dump_fname.tar.xz",
            "mbdump/$dump_fname",
            'JSON_DUMPS_SCHEMA_NUMBER',
        );
    } else {
        move($mbdump->export_dir,
             catdir($mbdump->output_dir, $dump_fname)) or die $OS_ERROR;
    }

    return;
}

sub write_json {
    my ($self, $dump_path, $entities_json_array) = @_;

    return unless @{$entities_json_array};

    my $lock_path = "$dump_path.lock";
    open(my $lock_fh, '>', $lock_path) or die $OS_ERROR;
    flock $lock_fh, LOCK_EX or die $OS_ERROR;

    open (my $dump_fh, '>>', $dump_path) or die $OS_ERROR;
    print $dump_fh "\n" if -s $dump_path;
    print $dump_fh (join "\n", @{$entities_json_array});
    close $dump_fh;

    flock $lock_fh, LOCK_UN or die $OS_ERROR;
}

sub fetch_entities_json {
    my ($self, $c, $entity_type, $replication_sequence, $last_modified,
        $callback, %options) = @_;

    die 'Option is_full_dump not specified'
        unless defined $options{is_full_dump};

    my $ids = $options{ids} // [];

    if (@{$ids}) {
        # We have the ids, so we can fetch them directly.
        my $it = natatime $BATCH_SIZE, @{$ids};
        while (my @next_ids = $it->()) {
            $self->_fetch_entities_json(
                $c, $entity_type, $replication_sequence, $last_modified,
                \@next_ids, $callback, %options
            );
        }
    } else {
        # Create a cursor across the entire table (or part of the table
        # we're dumping, e.g. standalone recordings).
        my $sql =
            'DECLARE csr NO SCROLL CURSOR FOR ' .
            'SELECT e.id FROM ' . $entity_type . ' e';

        my @conditions;
        my @params;

        if ($entity_type eq 'recording') {
            $sql .= ' LEFT JOIN track t ON t.recording = e.id';
            push @conditions, 't.id IS NULL';
        }

        if (defined $options{gt_id} && defined $options{lte_id}) {
            push @conditions, 'e.id > ? AND e.id <= ?';
            push @params, @options{qw( gt_id lte_id )};
        }

        if (@conditions) {
            $sql .= ' WHERE ' . (join ' AND ', @conditions);
        }

        state $csr_conn = DatabaseConnectionFactory->get_connection(
            $self->database,
            fresh => 1,
        );

        $csr_conn->sql->begin;
        $csr_conn->sql->do($sql, @params);

        while (1) {
            my $next_ids = $csr_conn->sql->select_single_column_array(
                "FETCH FORWARD $BATCH_SIZE FROM csr");

            last unless @{$next_ids};

            $self->_fetch_entities_json(
                $c, $entity_type, $replication_sequence, $last_modified,
                $next_ids, $callback, %options
            );
        }

        $csr_conn->sql->commit;
    }

    return;
}

sub _fetch_entities_json {
    my ($self, $c, $entity_type, $replication_sequence, $last_modified,
        $ids, $callback, %options) = @_;

    my $table = "json_dump.${entity_type}_json";

    # The full dump can fetch JSON from an older sequence if it hasn't
    # changed since. But the incremental dump needs the JSON at exactly
    # $replication_sequence, in order to detect changes.
    my $query;
    my %found;
    my @missing;
    my $is_full_dump = $options{is_full_dump};
    # XXX Until MBS-10911 can be resolved, have the full dumps fetch
    # all JSON anew to prevent it from becoming stale for too long.
    #my ($force_update) = grep { $_ eq $entity_type } @{ $options{force_update} // [] };
    my $force_update = $is_full_dump;

    if ($force_update) {
        # Don't retrieve anything.
        @missing = @{$ids};

    } elsif ($is_full_dump) {
        # If there are multiple JSON entries for different replication
        # sequences, select the newest sequence.
        $query = <<"SQL";
            SELECT * FROM (
             SELECT id, replication_sequence, json::text,
                    rank() OVER (PARTITION BY id
                                 ORDER BY replication_sequence DESC)
               FROM $table t
              WHERE id = any(\$1)
                AND replication_sequence <= \$2
            ) x WHERE rank = 1
SQL
    } else {
        $query = <<"SQL";
            SELECT id, replication_sequence, json::text
              FROM $table t
             WHERE id = any(\$1)
               AND replication_sequence = \$2
SQL
    }

    if (defined $query) {
        my $query_results = $c->sql->select_list_of_hashes(
            $query, $ids, $replication_sequence);

        for my $row (@{$query_results}) {
            $found{$row->{id}} = $row->{json};
        }

        for my $id (@{$ids}) {
            push @missing, $id unless $found{$id};
        }
    }

    if (@missing) {
        # We can only make requests against the current state of the
        # database, obviously. So $replication_sequence should match the
        # $current_replication_sequence (otherwise that's impossible).
        #
        # Fortunately, this should be the case. In the full dump, there
        # should be no missing rows unless this is the current replication
        # sequence (on first execution). In the incremental dump, we should
        # always be on the current replication sequence.
        #
        # Bugs happen, though, so if we're generating a full dump and there
        # are missing rows when there shouldn't be, we warn and allow it to
        # fetch the latest versions of those entities. If we didn't do that,
        # the full dumps would never self-correct, and those entities would
        # always remain missing.
        #
        # If $force_update is enabled, then we treat everything as missing
        # regardless of whether it actually is, so these warnings are
        # suppressed.
        #
        # FIXME: There seem to be entities "missing" for every dump no
        # matter what. Are we somehow selecting entities added in a later
        # replication sequence?
        my $current_replication_sequence = $c->sql->select_single_value(
            'SELECT current_replication_sequence FROM replication_control'
        );
        unless ($force_update || $replication_sequence == $current_replication_sequence) {
            my $message =
                'There are entities missing for replication sequence ' .
                $replication_sequence . " from the ${entity_type}_json " .
                'table, but the current replication sequence is ' .
                $current_replication_sequence . ': ' .
                Dumper([@missing > 15 ? (@missing[0 .. 14], '...') : @missing]);

            if ($options{is_full_dump}) {
                warn $message;
            } else {
                die $message;
            }
        }

        $self->insert_entities_json(
            $c,
            $entity_type,
            $current_replication_sequence,
            $last_modified,
            \@missing,
            \%found,
            $is_full_dump,
        );
    }

    $callback->(\%found) if %found;
    return;
}

sub insert_entities_json {
    my ($self, $c, $entity_type, $replication_sequence, $last_modified,
        $ids, $json_hash, $is_full_dump) = @_;

    state $json = JSON::XS->new->utf8;

    my $result = retry(
        sub { json_lookup($c, $entity_type, $ids) },
        reason => 'looking up JSON',
    );
    my @inserts;

    my $commit_inserts = sub {
        my $values_placeholders =
            join q(, ), (('(?, ?, ?, ?)') x (@inserts / 4));

        # retry: transient "server closed the connection unexpectedly" errors
        # have happened here.
        retry(sub {
            $c->sql->auto_commit(1);
            $c->sql->do(<<"SQL", @inserts);
                INSERT INTO json_dump.${entity_type}_json
                    (id, replication_sequence, json, last_modified)
                VALUES $values_placeholders
                ON CONFLICT DO NOTHING
SQL
        }, reason => 'inserting JSON');
        @inserts = ();
    };

    for my $id (keys %{$result}) {
        my $json_text = $json->encode($result->{$id});
        $json_hash->{$id} = $json_text if defined $json_hash;
        push @inserts,
            $id, $replication_sequence, $json_text, $last_modified;
        $commit_inserts->() if (@inserts / 4) >= 100;
    }

    $commit_inserts->() if @inserts;

    # Delete data older than any current replication sequence we need. It's
    # not guaranteed that every entity will have an entry for anything newer
    # or even equal to the oldest sequence we need, so only enter deletions
    # where they do.
    my $min_needed_sequence;
    if ($is_full_dump) {
        $min_needed_sequence = $replication_sequence;
    } else {
        $min_needed_sequence = $c->sql->select_single_value(
            'SELECT full_json_dump_replication_sequence ' .
            'FROM json_dump.control LIMIT 1',
        );
    }

    die 'Unable to determine a full_json_dump_replication_sequence'
        unless defined $min_needed_sequence;

    # retry: transient "server closed the connection unexpectedly" errors
    # have happened here.
    retry(sub {
        $c->sql->auto_commit(1);
        $c->sql->do(<<"SQL", $ids, $min_needed_sequence);
            DELETE FROM json_dump.${entity_type}_json a
             WHERE a.id = any(\$1)
               AND a.replication_sequence < \$2
               AND EXISTS (SELECT 1 FROM json_dump.${entity_type}_json b
                            WHERE b.id = a.id AND b.replication_sequence >= \$2)
SQL
    }, reason => 'deleting unneeded JSON');

    return;
}

sub with_incremental_dump_lock {
    my ($self, $callback) = @_;

    my $lock_path = '/tmp/.json-dump-incremental.lock';
    open(my $lock_fh, '>', $lock_path) or die $OS_ERROR;
    flock $lock_fh, LOCK_EX or die $OS_ERROR;

    eval { $callback->() };
    my $error = $EVAL_ERROR;

    flock $lock_fh, LOCK_UN or die $OS_ERROR;
    close $lock_fh;

    die $error if $error;
    return;
}

sub run {
    my ($self) = @_;

    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $self->database,
        fresh_connector => 1,
    );

    my $exit_code = $self->run_impl($c);

    $c->connector->disconnect;
    rmtree($TMP_EXPORT_DIR);

    log_info { 'Done' };
    return $exit_code;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
