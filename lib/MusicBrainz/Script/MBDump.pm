package MusicBrainz::Script::MBDump;

use base 'Exporter';

use DBDefs;
use Encode qw( encode );
use MusicBrainz::Script::Utils qw( log );
use Time::HiRes qw( gettimeofday tv_interval );

# overrides the user-specified $keep_files
our $erase_files_on_exit = 1;
our $export_dir = '';
our $output_dir = '.';
our $row_counts = {};

our $total_tables = 0;
our $total_rows = 0;

our @EXPORT_OK = qw(
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

1;
