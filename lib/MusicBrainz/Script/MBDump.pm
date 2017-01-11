package MusicBrainz::Script::MBDump;

use base 'Exporter';

use DBDefs;
use Encode qw( encode );
use Fcntl qw( LOCK_EX );
use File::Temp qw( tempdir );
use MusicBrainz::Script::Utils qw( log );
use Time::HiRes qw( gettimeofday tv_interval );

our $keep_files = 0;
# overrides the user-specified $keep_files
our $erase_files_on_exit = 1;
our $tmp_dir = '/tmp';
our $export_dir = '';
our $output_dir = '.';
our $row_counts = {};

our $total_tables = 0;
our $total_rows = 0;
our $start_time;
our $lock_fh;

our @EXPORT_OK = qw(
    begin_dump
    copy_readme
    dump_table
    gpg_sign
    make_tar
    write_file
);

sub copy_readme() {
    write_file('README', <<EOF);
The files in this directory are snapshots of the MusicBrainz database,
in a format suitable for import into a PostgreSQL database. To import
them, you need a compatible version of the MusicBrainz server software.
EOF
}

sub gpg_sign {
    my ($file_to_be_signed) = @_;

    my $sign_with = DBDefs->GPG_SIGN_KEY;
    return unless $sign_with;

    system 'gpg',
           '--default-key', $sign_with,
           '--detach-sign',
           '--armor',
           $file_to_be_signed;

    if ($? != 0) {
        print STDERR "Failed to sign $file_to_be_signed\n",
                     "GPG returned $?\n";
    }
}

sub make_tar {
    my ($tar_file, @tables) = @_;

    my @files = map { "mbdump/$_" }
                grep { $row_counts->{$_} } @tables;

    # These ones go first, so MBImport can quickly find them.
    unshift @files, qw(
        TIMESTAMP
        COPYING
        README
        REPLICATION_SEQUENCE
        SCHEMA_SEQUENCE
    );

    my $t0 = [gettimeofday];
    log("Creating $tar_file");
    chomp (my $tar_bin = `which gtar` || `which tar`);
    system $tar_bin,
           '-C', $export_dir,
           '--bzip2',
           '--create',
           '--verbose',
           '--file', "$output_dir/$tar_file",
           '--',
           @files;

    $? == 0 or die "Tar returned $?";
    log(sprintf "Tar completed in %d seconds\n", tv_interval($t0));

    gpg_sign("$output_dir/$tar_file");
}

sub write_file {
    my ($file, $contents) = @_;

    open(my $fh, ">$export_dir/$file") or die $!;
    print $fh $contents or die $!;
    close $fh or die $!;
}

sub table_rowcount {
    my ($c, $table) = @_;

    $table =~ s/_sanitised$//;
    $table =~ s/.*\.//;

    $c->sql->select_single_value(
        'SELECT reltuples FROM pg_class WHERE relname = ? LIMIT 1',
        $table,
    );
}

sub dump_table {
    my ($c, $table) = @_;

    my $table_file_path = "$export_dir/mbdump/$table";
    open(DUMP, ">$table_file_path") or die $!;

    my $rows_estimate = $row_counts->{$table} // table_rowcount($c, $table) // 1;
    my $dbh = $c->dbh; # issues a ping, must be done before COPY
    $c->sql->do("COPY $table TO stdout");

    my $buffer;
    my $rows = 0;
    my $t1 = [gettimeofday];
    my $interval;

    my $p = sub {
        my ($pre, $post) = @_;
        no integer;
        printf $pre . '%-30.30s %9d %3d%% %9d' . $post,
               $table, $rows, int(100 * $rows / ($rows_estimate || 1)),
               $rows / ($interval || 1);
    };

    $p->('', '') if -t STDOUT;

    my $longest = 0;
    while ($dbh->pg_getcopydata($buffer) >= 0) {
        $longest = length($buffer) if length($buffer) > $longest;
        print DUMP encode('utf-8', $buffer) or die $!;

        ++$rows;
        unless ($rows & 0xFFF) {
            $interval = tv_interval($t1);
            $p->("\r", '') if -t STDOUT;
        }
    }

    close DUMP or die $!;

    $interval = tv_interval($t1);
    $p->((-t STDOUT ? "\r" : ''), sprintf(" %.2f sec\n", $interval));
    print "Longest buffer used: $longest\n" if $ENV{SHOW_BUFFER_SIZE};

    $total_tables++;
    $total_rows += $rows;
    $row_counts->{$table} = $rows;

    $table_file_path;
}

sub begin_dump {
    my $c = shift;

    $start_time = gettimeofday;
    $export_dir = tempdir('mbexport-XXXXXX', DIR => $tmp_dir, CLEANUP => 0);
    mkdir "$export_dir/mbdump" or die $!;
    log("Exporting to $export_dir");

    END {
        if (
            $erase_files_on_exit &&
            !$keep_files &&
            defined($export_dir) &&
            -d $export_dir &&
            -d "$export_dir/mbdump"
        ) {
            log('Disk space just before erasing tmp dir:');
            system '/bin/df -m';
            log("Erasing $export_dir");
            system '/bin/rm', '-rf', $export_dir;
        }
    }

    # A quick discussion of the "Can't serialize access due to concurrent
    # update" problem. See "transaction-iso.html" in the Postgres
    # documentation. Basically the problem is this: export "A" starts; export
    # "B" starts; export "B" updates replication_control; export "A" then
    # can't update replication_control, failing with the above error. The
    # solution is to get a lock (outside of the database) before we start the
    # serializable transaction.
    open($lock_fh, '>>' . $tmp_dir . '/.mb-export-lock') or die $!;
    flock($lock_fh, LOCK_EX) or die $!;

    my $sql = $c->sql;
    $sql->auto_commit;
    $sql->do(q{SET SESSION CHARACTERISTICS
               AS TRANSACTION ISOLATION LEVEL SERIALIZABLE});
    $sql->begin;

    # Write the TIMESTAMP file.
    # This used to be free text; now it's parseable. It contains a PostgreSQL
    # TIMESTAMP WITH TIME ZONE expression.
    my $now = $sql->select_single_value('SELECT NOW()');
    write_file('TIMESTAMP', "$now\n");

    # Write the README file.
    copy_readme();

    my $schema_sequence = $sql->select_single_value(
        'SELECT current_schema_sequence FROM replication_control'
    );
    my $dbdefs_schema_sequence = DBDefs->DB_SCHEMA_SEQUENCE;
    $schema_sequence
        or die "Don't know what schema sequence number we're using";
    $schema_sequence == $dbdefs_schema_sequence
        or die "Stored schema sequence ($schema_sequence) does not match " .
               "DBDefs->DB_SCHEMA_SEQUENCE ($dbdefs_schema_sequence)";

    # Write the SCHEMA_SEQUENCE file. Again, this is parseable - it's just an
    # integer.
    write_file('SCHEMA_SEQUENCE', "$schema_sequence\n");
    write_file('REPLICATION_SEQUENCE', '');

    $| = 1;
    printf "%-30.30s %9s %4s %9s\n",
           qw(Table Rows est% rows/sec);
}

1;
