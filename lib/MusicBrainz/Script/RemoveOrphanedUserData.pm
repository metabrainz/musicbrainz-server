package MusicBrainz::Script::RemoveOrphanedUserData;

use Moose;
use namespace::autoclean;
use Readonly;

=head1 DESCRIPTION

This script cleans up user data left orphaned after an account is deleted.

Some accounts have a very large amount of tags or ratings linked to them.
Deletion of this data is performed asynchronously so as not to block or
time out the deletion endpoint in MusicBrainz Server.

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

use MusicBrainz::Errors qw( capture_exceptions );
use MusicBrainz::Server::Constants qw( entities_with );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Log qw( log_info );

with 'MooseX::Runnable',
     'MooseX::Getopt',
     'MusicBrainz::Script::Role::Context';

Readonly our $BATCH_SIZE => 500;

sub run {
    my ($self) = @_;

    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $self->database,
    );

    my @tables = sort { $a cmp $b } (
        (map { "${_}_rating_raw" } entities_with('ratings')),
        (map { "${_}_tag_raw" } entities_with('tags')),
    );

    $c->sql->begin;

    for my $table (@tables) {
        # Perform the deletion in batches. See the final example here:
        # https://www.postgresql.org/docs/18/sql-delete.html#id-1.9.3.100.9
        my $query = <<~"SQL";
            WITH batch AS (
                SELECT ctid
                FROM $table
                WHERE editor IN (SELECT id FROM editor WHERE deleted)
                FOR UPDATE
                LIMIT \$1
            )
            DELETE FROM $table AS t
            USING batch AS b
            WHERE t.ctid = b.ctid
            SQL

        my $total_row_count = 0;
        while (1) {
            my $batch_row_count = $c->sql->do($query, $BATCH_SIZE);
            $total_row_count += $batch_row_count;
            last if $batch_row_count <= 0;
        }

        log_info {
            "Deleting $total_row_count " .
            ($total_row_count > 1 ? 'rows ' : 'row ') .
            "from $table"
        } if $total_row_count > 0;
    }

    $c->sql->commit;
}

1;
