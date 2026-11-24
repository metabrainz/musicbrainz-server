package MusicBrainz::Script::RemoveResidualUserData;

use List::AllUtils qw( uniq );
use Moose;
use namespace::autoclean;
use Readonly;

=head1 DESCRIPTION

Usage: RemoveResidualUserData [OPTIONS]

Options:
    --database      database to use
                    (default: MAINTENANCE)

    --[no-]dry-run  perform a trial run without removing any data
                    (default: disabled)

This script cleans up residual user data (currently tags, ratings) left
behind after an account is deleted.

Deletion of such data is performed asynchronously so as not to block or
time out the deletion endpoint in MusicBrainz Server. Some accounts have a
very large number of tags or ratings linked to them; each individual tag
or rating deletion triggers a call to one of the following SQL functions:

 * `update_tag_counts_for_raw_delete`
 * `update_aggregate_rating_for_raw_delete`

These are expensive functions to call thousands of times in a single
transaction, so this script works by deleting the data in separate batches.

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

use MusicBrainz::Server::Constants qw( entities_with );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Log qw( log_info );
use Sql;

with 'MooseX::Runnable',
     'MooseX::Getopt',
     'MusicBrainz::Script::Role::Context';

has dry_run => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
    traits => [ 'Getopt' ],
    cmd_flag => 'dry-run',
    documentation => (
        'perform a trial run without removing any data ' .
        '(default: disabled)'
    ),
);

Readonly our $BATCH_SIZE => 500;

sub run {
    my ($self) = @_;

    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $self->database,
    );
    my $sql = $c->sql;

    my @tables = sort { $a cmp $b } (
        (map { "${_}_rating_raw" } entities_with('ratings')),
        (map { "${_}_tag_raw" } entities_with('tags')),
    );
    my @all_editor_ids;

    for my $table (@tables) {
        my $editor_ids = Sql::run_in_transaction(sub {
            $sql->select_single_column_array(<<~"SQL");
                SELECT DISTINCT editor
                FROM $table
                WHERE editor IN (SELECT id FROM editor WHERE deleted)
                SQL
        }, $sql);
        my $editor_count = scalar(@$editor_ids);

        log_info {
            "Identified $editor_count " .
            ($editor_count == 1 ? 'editor ' : 'editors ') .
            "with residual data in ${table}" .
            ($editor_count > 0 ? ': ' . (join q(, ), @$editor_ids) : '')
        };

        next if $self->dry_run;

        # Perform the deletion in batches. This query has been adapted from
        # the final example here:
        # https://www.postgresql.org/docs/18/sql-delete.html#id-1.9.3.100.9
        my $query = <<~"SQL";
            WITH batch AS (
                SELECT ctid
                FROM $table
                WHERE editor = any(\$1)
                FOR UPDATE
                LIMIT \$2
            )
            DELETE FROM $table AS t
            USING batch AS b
            WHERE t.ctid = b.ctid
            SQL

        my $total_row_count = 0;
        while (1) {
            my $batch_row_count = Sql::run_in_transaction(sub {
                $sql->do($query, $editor_ids, $BATCH_SIZE);
            }, $sql);
            $total_row_count += $batch_row_count;
            last if $batch_row_count <= 0;
        }

        log_info {
            "Deleted $total_row_count " .
            ($total_row_count == 1 ? 'row ' : 'rows ') .
            "from $table"
        } if $total_row_count > 0;

        push @all_editor_ids, @$editor_ids;
    }

    unless ($self->dry_run) {
        @all_editor_ids = uniq @all_editor_ids;
        Sql::run_in_transaction(sub {
            $c->model('Editor')->hard_delete_if_unreferenced(@all_editor_ids);
        }, $sql);
    }

    return 0;
}

1;
