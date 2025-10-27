package MusicBrainz::Script::Utils;
use strict;
use warnings;

use Encode;
use English;
use List::AllUtils qw( uniq );
use Time::HiRes qw( gettimeofday tv_interval );

use feature 'state';

use base 'Exporter';

our @EXPORT_OK = qw(
    copy_table_from_file
    find_files
    find_mbdump_file
    get_foreign_keys
    get_primary_keys
    is_table_empty
    log
    retry
);

=sub copy_table_from_file

Imports C<$file> into C<$table> via PostgreSQL's C<COPY> statement.

Returns the number of rows imported.

=cut

sub copy_table_from_file {
    my ($sql, $table, $file, %opts) = @_;

    my $delete_first = $opts{delete_first};
    my $fix_utf8 = $opts{fix_utf8};
    my $ignore_errors = $opts{ignore_errors};
    my $quiet = $opts{quiet};
    my $show_progress = !$quiet && ($opts{show_progress} // (-t STDOUT));

    print localtime() . " : load $table\n"
        unless $quiet;

    my $rows = 0;
    my $t1 = [gettimeofday];
    my $interval;

    my $size = -s($file)
        or return 1;

    my $p = sub {
        my ($pre, $post) = @_;
        no integer;
        printf $pre.'%-30.30s %9d %3d%% %9d'.$post,
                $table, $rows, int(100 * tell(LOAD) / $size),
                $rows / ($interval || 1);
    };

    $OUTPUT_AUTOFLUSH = 1;

    eval {
        # Open in :bytes mode (always keep byte octets), to allow fixing of
        # invalid UTF-8 byte sequences in --fix-broken-utf8 mode.
        # In default mode, the Pg driver will take care of the UTF-8
        # transformation and croak on any invalid UTF-8 character.
        open(LOAD, '<:bytes', $file) or die "open $file: $OS_ERROR";

        # If you're looking at this code because your import failed, maybe
        # with an error like this:
        #   ERROR:  copy: line 1, Missing data for column "automodsaccepted"
        # then the chances are it's because the data you're trying to load
        # doesn't match the structure of the database you're trying to load
        # it into. Please make sure you've got the right copy of the server
        # code, as described in the INSTALL file.

        $sql->begin;
        $sql->do("DELETE FROM $table") if $delete_first;

        my $dbh = $sql->dbh; # issues a ping, must be done before COPY
        $sql->do("COPY $table FROM stdin");

        $p->('', '') if $show_progress;

        my $t;
        while (<LOAD>) {
            $t = $_;
            if ($fix_utf8) {
                # Replaces any invalid UTF-8 character with special 0xFFFD
                # codepoint and warn on any such occurence.
                $t = Encode::decode('UTF-8', $t,
                                    Encode::FB_DEFAULT |
                                    Encode::WARN_ON_ERR);
            } else {
                $t = Encode::decode('UTF-8', $t, Encode::FB_CROAK);
            }
            if (!$dbh->pg_putcopydata($t)) {
                print 'ERROR while processing: ', $t;
                die;
            }

            ++$rows;
            unless ($rows & 0xFFF) {
                $interval = tv_interval($t1);
                $p->("\r", '') if $show_progress;
            }
        }

        $dbh->pg_putcopyend or die;

        $interval = tv_interval($t1);
        $p->(($show_progress ? "\r" : ''),
             sprintf(" %.2f sec\n", $interval))
            unless $quiet;

        close LOAD
            or die $OS_ERROR;

        $sql->commit;

        die 'Error loading data'
            if -f $file and is_table_empty($sql, $table);

        1;
    };

    return $rows unless $EVAL_ERROR;
    warn "Error loading $file: $EVAL_ERROR";
    $sql->rollback;

    return 0 if $ignore_errors;
    exit 1;
}

=sub find_files

Looks for files named C<$file> in C<@search_paths>. The given paths may
contain a direct reference to the file, or directories which will be checked
instead.

Returns an array of found files (in the specified search order).

=cut

sub find_files {
    my ($file, @search_paths) = @_;

    return uniq(grep { -f } map {
        my $search_path = $_;
        (
            ($search_path =~ m/\Q$file\E$/ ? $search_path : ()),
            "$search_path/$file"
        )
    } @search_paths);
}

=sub find_mbdump_file

Looks for an mbdump file named C<$table> in C<@search_paths>. The semantics
are the same as for C<find_files>, except:

 1. The file is additionally searched for under an 'mbdump' sub-directory in
    each search path.
 2. The first matching file is returned in scalar context.

=cut

sub find_mbdump_file {
    my ($table, @search_paths) = @_;

    my @result = find_files($table, map {
        ($_, "$_/mbdump")
    } @search_paths);

    return wantarray ? @result : $result[0];
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

=sub is_table_empty

Returns whether C<$table> is empty.

=cut

sub is_table_empty {
    my ($sql, $table) = @_;

    not defined $sql->select_single_value(<<~"SQL");
        SELECT 1 FROM $table LIMIT 1;
        SQL
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
