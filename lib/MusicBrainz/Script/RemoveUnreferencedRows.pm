package MusicBrainz::Script::RemoveUnreferencedRows;
use Moose;

use MusicBrainz::Errors qw( capture_exceptions );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Log qw( log_info );

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

has dry_run => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
    traits => [ 'Getopt' ],
    cmd_flag => 'dry-run'
);

sub run {
    my ($self) = @_;

    log_info { 'Checking all unreferenced rows.' };

    my @unreferenced_rows = @{
        $self->c->sql->select_list_of_lists(<<~'SQL');
              SELECT table_name,
                     array_agg(row_id) AS row_ids
                FROM unreferenced_row_log
               WHERE inserted < now() - '7 day'::interval
            GROUP BY table_name
            SQL
    };

    unless (@unreferenced_rows) {
        log_info {'No unreferenced rows found.'};
    }

    for my $table_group (@unreferenced_rows) {
        my ($table_name, $row_ids) = @$table_group;

        my $count = scalar @$row_ids;
        my $removed = 0;

        log_info {
            sprintf 'Found %d %s row%s unreferenced for 7 or more days.',
                $count, $table_name, ($count==1 ? '' : 's');
        };

        my $quoted_table_name =
            $self->c->sql->dbh->quote_identifier($table_name);

        for my $id (@$row_ids) {
            capture_exceptions(sub {
                Sql::run_in_transaction(sub {
                    # We want to ensure the row is still unreferenced
                    my $query = <<~"SQL";
                        SELECT ref_count
                          FROM $quoted_table_name
                         WHERE id = ?
                           FOR UPDATE
                        SQL

                    my $ref_count = $self->c->sql->select_single_value(
                        $query,
                        $id,
                    );

                    if ($ref_count == 0) {
                        log_info {
                            sprintf "Will remove id=%s from $table_name.",
                            $id,
                        };

                        unless ($self->dry_run) {
                            if ($table_name eq 'artist_credit') {
                                $self->sql->do(<<~'SQL', $id);
                                    DELETE FROM artist_credit_gid_redirect
                                          WHERE new_id = ?
                                    SQL
                            }

                            $self->c->sql->do(<<~"SQL", $id);
                                DELETE FROM $quoted_table_name
                                      WHERE id = ?
                                SQL

                            ++$removed;
                        }
                    } else {
                        log_info {
                            sprintf "Found references for id=%s from $table_name.",
                            $id,
                        };
                    }

                    unless ($self->dry_run) {
                        $self->c->sql->do(<<~'SQL', $table_name, $id);
                            DELETE FROM unreferenced_row_log
                                WHERE table_name = ?
                                    AND row_id = ?
                            SQL
                    }
                }, $self->c->sql);
            }, sub {
                my $err = shift;
                log_info { "Error while processing id $id from $table_name: $err\n" };
                return;
            });
        }

        unless ($self->dry_run) {
            if ($removed > 0) {
                log_info { sprintf 'Successfully removed %d unreferenced row%s.',
                    $removed, ($removed==1 ? '' : 's') };
            } else {
                log_info {'No rows were removed.'};
            }
        }
    }
}

1;
