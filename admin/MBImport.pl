#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Getopt::Long;
use DBDefs;
use Sql;
use MusicBrainz::Server::Replication qw( :replication_type );
use MusicBrainz::Server::Constants qw( @FULL_TABLE_LIST );

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

my ($fHelp, $fIgnoreErrors);
my $tmpdir = '/tmp';
my $fProgress = -t STDOUT;
my $fFixUTF8 = 0;
my $skip_ensure_editor = 0;
my $update_replication_control = 1;
my $delete_first = 0;
my $database = 'MAINTENANCE';

GetOptions(
    'help|h'                    => \$fHelp,
    'ignore-errors|i!'  => \$fIgnoreErrors,
    'tmp-dir|t=s'               => \$tmpdir,
    'database=s' => \$database,
    'fix-broken-utf8'   => \$fFixUTF8,
    'skip-editor!' => \$skip_ensure_editor,
    'update-replication-control!' => \$update_replication_control,
    'delete-first!' => \$delete_first
);

sub usage
{
    print <<EOF;
Usage: MBImport.pl [options] FILE ...

        --help            show this help
        --fix-broken-utf8 replace invalid UTF-8 byte sequences with a
                          special U+FFFD codepoint (UTF-8: 0xEF 0xBF 0xBD)
    -i, --ignore-errors   if a table fails to import, continue anyway
    -t, --tmp-dir DIR     use DIR for temporary storage (default: /tmp)
        --database        database to import into (default: MAINTENANCE)
        --skip-editor     do not guarantee editor rows are present (useful when
                          importing single tables).
        --update-replication-control whether or not this import should
                          alter the replication control table. This flag is
                          internal and is only be set by MusicBrainz scripts
        --delete-first    If set, will delete from non-empty tables immediately
                          before importing

FILE can be any of: a regular file in Postgres "copy" format (as produced
by ExportAllTables --nocompress); a gzip'd or bzip2'd tar file of Postgres
"copy" files (as produced by ExportAllTables); a directory containing
Postgres "copy" files; or a directory containing an "mbdump" directory
containing Postgres "copy" files.

If any "tar" files are named, they are firstly all
decompressed to temporary directories (under the directory named by
--tmp-dir).  These directories are removed on exit.

This script then proceeds through all of the MusicBrainz known table names,
and processes each as follows: firstly the file to load for that table
is identified, by considering each named argument in turn to see if it
provides a file for this table; if no file is available, processing of this
table ends.

Then, if the database table is not empty and delete-first is not set, a warning
is generated, and processing of this table ends.  Otherwise, the file is loaded
into the table.  (Exception: the "moderator_santised" file, if present, is
loaded into the "moderator" table).

Note: The --fix-broken-utf8 is usefull when upgrading a database to
      Postgres 8.1.x and your old database includes byte sequences that are
      invalid in UTF-8. It does not really fix the data, because the
      original encoding can't be determined automatically. Instead it
      replaces the affected byte sequence with the special Unicode "replacement
      character" U+FFFD. A warning is printed on every such replacement.
EOF
    exit;
}

$fHelp and usage();
@ARGV or usage();

my $mb = Databases->get_connection($database);
my $sql = Sql->new($mb->conn);


my @tar_to_extract;

for my $arg (@ARGV)
{
    -e $arg or die "'$arg' not found";
    next if -d _;
    -f _ or die "'$arg' is neither a regular file nor a directory";

    next unless $arg =~ /\.tar(?:\.(gz|bz2|xz))?$/;

    my $decompress = '';
    $decompress = '--gzip' if $1 and $1 eq 'gz';
    $decompress = '--bzip2' if $1 and $1 eq 'bz2';
    $decompress = '--xz' if $1 and $1 eq 'xz';

    use File::Temp qw( tempdir );
    my $dir = tempdir('MBImport-XXXXXXXX', DIR => $tmpdir, CLEANUP => 1)
        or die $!;

    validate_tar($arg, $dir, $decompress);
    push @tar_to_extract, [ $arg, $dir, $decompress ];

    $arg = $dir;
}

for (@tar_to_extract)
{
    my ($tar, $dir, $decompress) = @$_;
    print localtime() . " : tar -C $dir $decompress -xvf $tar\n";
    system "tar -C $dir $decompress -xvf $tar";
    exit($? >> 8) if $?;
}

print localtime() . " : Validating snapshot\n";

# We should have TIMESTAMP files, and they should all match.
my $timestamp = read_all_and_check('TIMESTAMP') || '';
# Old TIMESTAMP files used to have some blurb in front
$timestamp =~ s/^This snapshot was taken at //;
print localtime() . " : Snapshot timestamp is $timestamp\n";

# We should also have SCHEMA_SEQUENCE files, which match.  Plus they must
# match DBDefs->DB_SCHEMA_SEQUENCE.
my $SCHEMA_SEQUENCE = read_all_and_check('SCHEMA_SEQUENCE');
if (not defined $SCHEMA_SEQUENCE)
{
    print STDERR localtime() . " : No SCHEMA_SEQUENCE in import files - continuing anyway\n";
    print STDERR localtime() . " : Don't be surprised if this import fails\n";
    $| = 1, print(chr(7)), sleep 5
        if -t STDOUT;
} elsif ($SCHEMA_SEQUENCE != DBDefs->DB_SCHEMA_SEQUENCE) {
    printf STDERR "%s : Schema sequence mismatch - codebase is %d, snapshot files are %d\n",
        scalar localtime,
        DBDefs->DB_SCHEMA_SEQUENCE,
        $SCHEMA_SEQUENCE,
        ;
    exit 1;
}

# We should have REPLICATION_SEQUENCE files, and they should all match too.
my $iReplicationSequence = read_all_and_check('REPLICATION_SEQUENCE');
$iReplicationSequence = '' if not defined $iReplicationSequence;
print localtime() . " : This snapshot corresponds to replication sequence #$iReplicationSequence\n"
    if $iReplicationSequence ne '';
print localtime() . ' : This snapshot does not correspond to any replication sequence'
    . " - you will not be able to update this database using replication\n"
    if $iReplicationSequence eq '';

use Time::HiRes qw( gettimeofday tv_interval );
my $t0 = [gettimeofday];
my $totalrows = 0;
my $tables = 0;
my $errors = 0;

print localtime() . " : starting import\n";

printf "%-30.30s %9s %4s %9s\n",
    'Table', 'Rows', 'est%', 'rows/sec',
    ;

# Track which tables have been successfully imported
my %imported_tables;

ImportAllTables();

if(!$imported_tables{editor} && !$skip_ensure_editor) {
    print localtime() . " : ensuring editor information is present\n";
    EnsureEditorTable();
}

print localtime() . " : import finished\n";

my $dumptime = tv_interval($t0);
printf "Loaded %d tables (%d rows) in %d seconds\n",
    $tables, $totalrows, $dumptime;


# Set replication_control.current_replication_sequence according to
# REPLICATION_SEQUENCE.
# This is necessary because if the server did an export --with-full-export
# --without-replication, then replication_control.current_replication_sequence
# would be invalid - we should trust the REPLICATION_SEQUENCE file instead.
# The current_schema_sequence /is/ valid, however.

if ($update_replication_control) {
    $sql->auto_commit;
    $sql->do(
        'UPDATE replication_control
         SET current_replication_sequence = ?,
         last_replication_date = ?',
        ($iReplicationSequence eq '' ? undef : $iReplicationSequence),
        ($iReplicationSequence eq '' ? undef : $timestamp),
    );
}

exit($errors ? 1 : 0);



sub ImportTable
{
    my ($table, $file) = @_;

    print localtime() . " : load $table\n";

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
                $rows / ($interval||1);
    };

    $| = 1;

    eval
    {
        # open in :bytes mode (always keep byte octets), to allow fixing of invalid
        # UTF-8 byte sequences in --fix-broken-utf8 mode.
        # in default mode, the Pg driver will take care of the UTF-8 transformation
        # and croak on any invalid UTF-8 character
        open(LOAD, '<:bytes', $file) or die "open $file: $!";

        # If you're looking at this code because your import failed, maybe
        # with an error like this:
        #   ERROR:  copy: line 1, Missing data for column "automodsaccepted"
        # then the chances are it's because the data you're trying to load
        # doesn't match the structure of the database you're trying to load it
        # into.  Please make sure you've got the right copy of the server
        # code, as described in the INSTALL file.

        $sql->begin;
        $sql->do("DELETE FROM $table") if $delete_first;
        my $dbh = $sql->dbh; # issues a ping, must be done before COPY
        $sql->do("COPY $table FROM stdin");

        $p->('', '') if $fProgress;
        my $t;

        use Encode;
        while (<LOAD>)
        {
                $t = $_;
                if ($fFixUTF8) {
                        # replaces any invalid UTF-8 character with special 0xFFFD codepoint
                        # and warn on any such occurence
                        $t = Encode::decode('UTF-8', $t, Encode::FB_DEFAULT | Encode::WARN_ON_ERR);
                } else {
                        $t = Encode::decode('UTF-8', $t, Encode::FB_CROAK);
                }
                if (!$dbh->pg_putcopydata($t))
                {
                        print 'ERROR while processing: ', $t;
                        die;
                }

                ++$rows;
                unless ($rows & 0xFFF)
                {
                        $interval = tv_interval($t1);
                        $p->("\r", '') if $fProgress;
                }
        }
        $dbh->pg_putcopyend() or die;
        $interval = tv_interval($t1);
        $p->(($fProgress ? "\r" : ''), sprintf(" %.2f sec\n", $interval));

        close LOAD
                or die $!;

        $sql->commit;

        die 'Error loading data'
                if -f $file and empty($table);

        ++$tables;
        $totalrows += $rows;

        1;
    };

    return 1 unless $@;
    warn "Error loading $file: $@";
    $sql->rollback;

    ++$errors, return 0 if $fIgnoreErrors;
    exit 1;
}

sub empty
{
    my $table = shift;

    my $any = $sql->select_single_value(
        "SELECT 1 FROM $table LIMIT 1",
    );

    not defined $any;
}

sub ImportAllTables
{
    for my $table (@FULL_TABLE_LIST) {
        my $file = (find_file($table))[0];
        $file or print("No data file found for '$table', skipping\n"), next;
        $imported_tables{$table} = 1;

        if (DBDefs->REPLICATION_TYPE == RT_MIRROR)
        {
                my $basetable = $table;
                $basetable =~ s/_sanitised$//;
        }

        if ($table =~ /^(.*)_sanitised$/)
        {
                my $basetable = $1;

                if (not empty($basetable) and not $delete_first)
                {
                        warn "$basetable table already contains data; skipping $table\n";
                        next;
                }

                print localtime() . " : loading $file into $basetable\n";
                ImportTable($basetable, $file) or next;

        } else {
                if (not empty($table) and not $delete_first)
                {
                        warn "$table already contains data; skipping\n";
                        next;
                }

                ImportTable($table, $file);
        }
    }

    return 1;
}

sub find_file
{
    my $table = shift;
    my @r;

    for my $arg (@ARGV)
    {
        use File::Basename;
        push(@r, $arg), next if -f $arg and basename($arg) eq $table;
        push(@r, "$arg/$table"), next if -f "$arg/$table";
        push(@r, "$arg/mbdump/$table"), next if -f "$arg/mbdump/$table";
    }

    @r;
}

sub read_all_and_check
{
    my $file = shift;

    my @files = find_file($file);
    my %contents;
    my %uniq;

    for my $foundfile (@files)
    {
        open(my $fh, "<$foundfile") or die $!;
        my $contents = do { local $/; <$fh> };
        close $fh;
        $contents{$foundfile} = $contents;
        ++$uniq{$contents};
    }

    chomp(my @v = sort keys %uniq);

    if (@v > 1)
    {
        print STDERR localtime(). " : Aborting import - your $file files don't match!\n";
        print STDERR localtime(). " : The different $file files follow:\n";
        print STDERR " $_\n" for @v;
        exit 1;
    }

    $v[0];
}

sub validate_tar
{
    my ($tar, $dir, $decompress) = @_;

    # One of the more annoying things that can go wrong with imports is
    # schema sequence mismatches.  It's annoying because this script has to
    # first decompress and extract all the tar files, which take a while.
    # /Then/ the error is uncovered, the script exits, all the extracted
    # data is wiped, and you have to start again.  Grrr.

    # Here we extract just the first 100Kb of each tar file, which should
    # contain all the relevant SCHEMA_SEQUENCE, TIMESTAMP files etc.

    my $cat_cmd = (
        not($decompress) ? 'cat'
        : $decompress eq '--gzip' ? 'gunzip'
        : $decompress eq '--bzip2' ? 'bunzip2'
        : $decompress eq '--xz' ? 'xz -d'
        : die
    );

    print localtime() . " : Pre-checking $tar\n";
    system "$cat_cmd < $tar | head -c 102400 | tar -C $dir -xf- 2>/dev/null";

    if (open(my $fh, '<', "$dir/SCHEMA_SEQUENCE"))
    {
        my $all = do { local $/; <$fh> };
        close $fh;
        chomp($all);
        if ($all ne DBDefs->DB_SCHEMA_SEQUENCE)
        {
                printf STDERR "%s : Schema sequence mismatch - codebase is %d, $tar is %d\n",
                        scalar localtime,
                        DBDefs->DB_SCHEMA_SEQUENCE,
                        $all,
                        ;
                exit 1;
        }
    }
}

sub EnsureEditorTable {
    $sql->begin;
    $sql->do(
        q{INSERT INTO editor (id, name, password, ha1)
             SELECT DISTINCT s.editor, 'Editor #' || s.editor::text, '', ''
             FROM (
                 SELECT editor FROM annotation
             UNION ALL
                 SELECT editor FROM edit
             UNION ALL
                 SELECT editor FROM edit_note
             UNION ALL
                 SELECT editor FROM vote
             ) s
             LEFT JOIN editor ON s.editor = editor.id
             WHERE editor.id IS NULL}
    );
    $sql->commit;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 1998 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
