package MusicBrainz::Script::Utils;
use strict;
use warnings;

use Encode;
use English;
use Time::HiRes qw( gettimeofday tv_interval );

use feature 'state';

use base 'Exporter';

our @EXPORT_OK = qw(
    copy_table_from_file
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
