package MusicBrainz::Script::Utils;
use strict;
use warnings;

use English;
use File::Basename qw( basename );
use List::AllUtils qw( uniq );

use feature 'state';

use base 'Exporter';

our @EXPORT_OK = qw(
    find_mbdump_file
    get_primary_keys
    get_foreign_keys
    log
    retry
);

=sub find_mbdump_file

Looks for an mbdump file named C<$table> in C<@search_paths>. The given paths
may contain a direct reference to the file, or directories which will be
checked instead.

Returns an array of found files (in the specified search order) in list
context, or the first such match in scalar context.

=cut

sub find_mbdump_file {
    my ($table, @search_paths) = @_;

    my @r;
    for my $arg (@search_paths) {
        push(@r, $arg), next if -f $arg and basename($arg) eq $table;
        push(@r, "$arg/$table"), next if -f "$arg/$table";
        push(@r, "$arg/mbdump/$table"), next if -f "$arg/mbdump/$table";
    }
    return wantarray ? uniq(@r) : $r[0];
}

=sub get_foreign_keys

Get a list of foreign key columns for (C<$schema>, C<$table>).

Returns an array ref of hashes containing the following keys:
 * pk_column
 * fk_schema
 * fk_table
 * fk_column

If C<$direction> is 1, then retrieves FK columns in other tables that refer
to PK columns in C<$table>.

If C<$direction> is 2, then retrieves FK columns in C<$table> that refer to
PK columns in other tables.

C<$cache> is a hash reference used to memoize return values.

=cut

sub get_foreign_keys {
    my ($dbh, $direction, $schema, $table, $cache) = @_;

    $cache //= {};

    my $cache_key = "$direction\t$schema\t$table";
    if (exists $cache->{$cache_key}) {
        return $cache->{$cache_key};
    }

    my $foreign_keys = [];
    my ($sth, $all_keys);

    if ($direction == 1) {
        # Get FK columns in other tables that refer to PK columns in $table.
        $sth = $dbh->foreign_key_info(undef, $schema, $table, (undef) x 3);
        if (defined $sth) {
            $all_keys = $sth->fetchall_arrayref;
        }
    } elsif ($direction == 2) {
        # Get FK columns in $table that refer to PK columns in other tables.
        $sth = $dbh->foreign_key_info((undef) x 4, $schema, $table);
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

    $cache->{$cache_key} = $foreign_keys;
    return $foreign_keys;
}

=sub get_primary_keys

Get a list of primary key column names for $schema.$table.

=cut

sub get_primary_keys($$$) {
    my ($sql, $schema, $table) = @_;

    state $cache = {};
    if (defined $cache->{$table}) {
        return @{ $cache->{$table} };
    }

    # retry: transient "server closed the connection unexpectedly",
    # "no statement executing", and "Field 'attnum' does not exist" errors
    # have happened here.
    my @keys = retry(
        sub { $sql->dbh->primary_key(undef, $schema, $table) },
        reason => 'getting primary keys',
    );
    @keys = map {
        # Some columns are wrapped in quotes, others aren't...
        s/^"(.*?)"$/$1/r
    } @keys;
    $cache->{$table} = \@keys;
    return @keys;
}

=sub log

Log a message to stdout, prefixed with the local time and ending with a
newline.

=cut

sub log($) {
    print localtime . ' : ' . $_[0] . "\n";
}

=sub retry

Retry a callback upon errors, with exponential backoff.

=cut

sub retry {
    my ($callback, %opts) = @_;

    my $attempts_remaining = 5;
    my $delay = 15;
    my $reason = $opts{reason} // 'executing callback';
    while (1) {
        my $error;
        if (wantarray) {
            my @result = eval { $callback->() };
            $error = $EVAL_ERROR;
            return @result unless $error;
        } else {
            my $result = eval { $callback->() };
            $error = $EVAL_ERROR;
            return $result unless $error;
        }
        if ($attempts_remaining--) {
            MusicBrainz::Script::Utils::log(
                qq(Died ($reason), ) .
                qq(retrying in $delay seconds: $error));
        } else {
            die $error;
        }
        sleep $delay;
        $delay *= 2;
    }
}

1;
