#!/usr/bin/env perl

use warnings;
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Getopt::Long;
use DBDefs;
use Sql;
use MusicBrainz::Server::Replication qw( :replication_type NON_REPLICATED_TABLES );

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

my ($fHelp, $fIgnoreErrors);
my $tmpdir = "/tmp";
my $fProgress = -t STDOUT;
my $fFixUTF8 = 0;
my $skip_ensure_editor = 0;
my $update_replication_control = 1;

GetOptions(
    "help|h"                    => \$fHelp,
    "ignore-errors|i!"  => \$fIgnoreErrors,
    "tmp-dir|t=s"               => \$tmpdir,
    "fix-broken-utf8"   => \$fFixUTF8,
    "skip-editor!" => \$skip_ensure_editor,
    "update-replication-control!" => \$update_replication_control
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
        --skip-editor     do not guarantee editor rows are present (useful when
                          importing single tables).
        --update-replication-control whether or not this import should
                          alter the replication control table. This flag is
                          internal and is only be set by MusicBrainz scripts

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

Then, if the database table is not empty, a warning is generated, and
processing of this table ends.  Otherwise, the file is loaded into the table.
(Exception: the "moderator_santised" file, if present, is loaded into the
"moderator" table).

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

my $mb = Databases->get_connection('READWRITE');
my $sql = Sql->new($mb->conn);


my @tar_to_extract;

for my $arg (@ARGV)
{
    -e $arg or die "'$arg' not found";
    next if -d _;
    -f _ or die "'$arg' is neither a regular file nor a directory";

    next unless $arg =~ /\.tar(?:\.(gz|bz2))?$/;

    my $decompress = "";
    $decompress = "--gzip" if $1 and $1 eq "gz";
    $decompress = "--bzip2" if $1 and $1 eq "bz2";

    use File::Temp qw( tempdir );
    my $dir = tempdir("MBImport-XXXXXXXX", DIR => $tmpdir, CLEANUP => 1)
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
    exit $? if $?;
}

print localtime() . " : Validating snapshot\n";

# We should have TIMESTAMP files, and they should all match.
my $timestamp = read_all_and_check("TIMESTAMP") || "";
# Old TIMESTAMP files used to have some blurb in front
$timestamp =~ s/^This snapshot was taken at //;
print localtime() . " : Snapshot timestamp is $timestamp\n";

# We should also have SCHEMA_SEQUENCE files, which match.  Plus they must
# match DBDefs->DB_SCHEMA_SEQUENCE.
my $SCHEMA_SEQUENCE = read_all_and_check("SCHEMA_SEQUENCE");
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
my $iReplicationSequence = read_all_and_check("REPLICATION_SEQUENCE");
$iReplicationSequence = "" if not defined $iReplicationSequence;
print localtime() . " : This snapshot corresponds to replication sequence #$iReplicationSequence\n"
    if $iReplicationSequence ne "";
print localtime() . " : This snapshot does not correspond to any replication sequence"
    . " - you will not be able to update this database using replication\n"
    if $iReplicationSequence eq "";

use Time::HiRes qw( gettimeofday tv_interval );
my $t0 = [gettimeofday];
my $totalrows = 0;
my $tables = 0;
my $errors = 0;

print localtime() . " : starting import\n";

printf "%-30.30s %9s %4s %9s\n",
    "Table", "Rows", "est%", "rows/sec",
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
        "UPDATE replication_control
         SET current_replication_sequence = ?,
         last_replication_date = ?",
        ($iReplicationSequence eq "" ? undef : $iReplicationSequence),
        ($iReplicationSequence eq "" ? undef : $timestamp),
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
        printf $pre."%-30.30s %9d %3d%% %9d".$post,
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
        open(LOAD, "<:bytes", $file) or die "open $file: $!";

        # If you're looking at this code because your import failed, maybe
        # with an error like this:
        #   ERROR:  copy: line 1, Missing data for column "automodsaccepted"
        # then the chances are it's because the data you're trying to load
        # doesn't match the structure of the database you're trying to load it
        # into.  Please make sure you've got the right copy of the server
        # code, as described in the INSTALL file.

        $sql->begin;
        $sql->do("COPY $table FROM stdin");
        my $dbh = $sql->dbh;

        $p->("", "") if $fProgress;
        my $t;

        use Encode;
        while (<LOAD>)
        {
                $t = $_;
                if ($fFixUTF8) {
                        # replaces any invalid UTF-8 character with special 0xFFFD codepoint
                        # and warn on any such occurence
                        $t = Encode::decode("UTF-8", $t, Encode::FB_DEFAULT | Encode::WARN_ON_ERR);
                }
                if (!$dbh->pg_putcopydata($t))
                {
                        print "ERROR while processing: ", $t;
                        die;
                }

                ++$rows;
                unless ($rows & 0xFFF)
                {
                        $interval = tv_interval($t1);
                        $p->("\r", "") if $fProgress;
                }
        }
        $dbh->pg_putcopyend() or die;
        $interval = tv_interval($t1);
        $p->(($fProgress ? "\r" : ""), sprintf(" %.2f sec\n", $interval));

        close LOAD
                or die $!;

        $sql->commit;

        die "Error loading data"
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
    for my $table (qw(
        artist_rating_raw
        artist_tag_raw
        cdtoc_raw
        edit
        edit_area
        edit_artist
        edit_label
        edit_note
        edit_recording
        edit_release
        edit_release_group
        edit_url
        edit_work
        label_rating_raw
        label_tag_raw
        recording_rating_raw
        recording_tag_raw
        release_group_rating_raw
        release_group_tag_raw
        release_tag_raw
        release_raw
        track_raw
        vote
        work_rating_raw
        work_tag_raw
        annotation
        application
        area
        area_type
        area_alias
        area_alias_type
        area_annotation
        area_gid_redirect
        country_area
        iso_3166_1
        iso_3166_2
        iso_3166_3
        artist
        artist_alias
        artist_alias_type
        artist_annotation
        artist_credit
        artist_credit_name
        artist_gid_redirect
        artist_ipi
        artist_isni
        artist_meta
        artist_name
        artist_tag
        artist_type
        autoeditor_election
        autoeditor_election_vote
        cdtoc
        clientversion
        editor
        editor_oauth_token
        editor_preference
        editor_language
        editor_sanitised
        editor_subscribe_artist
        editor_subscribe_collection
        editor_subscribe_editor
        editor_subscribe_label
        editor_watch_artist
        editor_watch_preferences
        editor_watch_release_group_type
        editor_watch_release_status
        gender
        isrc
        iswc
        l_area_area
        l_area_artist
        l_area_label
        l_area_recording
        l_area_release
        l_area_release_group
        l_area_url
        l_area_work
        l_artist_artist
        l_artist_label
        l_artist_recording
        l_artist_release
        l_artist_release_group
        l_artist_url
        l_artist_work
        l_label_label
        l_label_recording
        l_label_release
        l_label_release_group
        l_label_url
        l_label_work
        l_recording_recording
        l_recording_release
        l_recording_release_group
        l_recording_url
        l_recording_work
        l_release_group_release_group
        l_release_group_url
        l_release_group_work
        l_release_release
        l_release_release_group
        l_release_url
        l_release_work
        l_url_url
        l_url_work
        l_work_work
        label
        label_alias
        label_alias_type
        label_annotation
        label_gid_redirect
        label_ipi
        label_isni
        label_meta
        label_name
        label_tag
        label_type
        language
        link
        link_attribute
        link_attribute_credit
        link_attribute_type
        link_creditable_attribute_type
        link_type
        link_type_attribute_type
        editor_collection
        editor_collection_release
        medium
        medium_cdtoc
        medium_format
        puid
        recording
        recording_annotation
        recording_gid_redirect
        recording_meta
        recording_puid
        recording_tag
        release
        release_annotation
        release_country
        release_gid_redirect
        release_group
        release_group_annotation
        release_group_gid_redirect
        release_group_meta
        release_group_tag
        release_group_primary_type
        release_group_secondary_type
        release_group_secondary_type_join
        release_label
        release_meta
        release_coverart
        release_name
        release_packaging
        release_status
        release_tag
        release_unknown_country
        replication_control
        script
        script_language
        tag
        tag_relation
        track
        track_gid_redirect
        track_name
        medium_index
        url
        url_gid_redirect
        work
        work_alias
        work_alias_type
        work_annotation
        work_attribute
        work_attribute_type
        work_attribute_type_allowed_value
        work_gid_redirect
        work_meta
        work_name
        work_tag
        work_type

        cover_art_archive.art_type
        cover_art_archive.image_type
        cover_art_archive.cover_art
        cover_art_archive.cover_art_type
        cover_art_archive.release_group_cover_art

        documentation.l_area_area_example
        documentation.l_area_artist_example
        documentation.l_area_label_example
        documentation.l_area_recording_example
        documentation.l_area_release_example
        documentation.l_area_release_group_example
        documentation.l_area_url_example
        documentation.l_area_work_example
        documentation.l_artist_artist_example
        documentation.l_artist_label_example
        documentation.l_artist_recording_example
        documentation.l_artist_release_example
        documentation.l_artist_release_group_example
        documentation.l_artist_url_example
        documentation.l_artist_work_example
        documentation.l_label_label_example
        documentation.l_label_recording_example
        documentation.l_label_release_example
        documentation.l_label_release_group_example
        documentation.l_label_url_example
        documentation.l_label_work_example
        documentation.l_recording_recording_example
        documentation.l_recording_release_example
        documentation.l_recording_release_group_example
        documentation.l_recording_url_example
        documentation.l_recording_work_example
        documentation.l_release_group_release_group_example
        documentation.l_release_group_url_example
        documentation.l_release_group_work_example
        documentation.l_release_release_example
        documentation.l_release_release_group_example
        documentation.l_release_url_example
        documentation.l_release_work_example
        documentation.l_url_url_example
        documentation.l_url_work_example
        documentation.l_work_work_example
        documentation.link_type_documentation

        statistics.statistic
        statistics.statistic_event

        wikidocs.wikidocs_index
    )) {
        my $file = (find_file($table))[0];
        $file or print("No data file found for '$table', skipping\n"), next;
        $imported_tables{$table} = 1;

        if (DBDefs->REPLICATION_TYPE == RT_SLAVE)
        {
                my $basetable = $table;
                $basetable =~ s/_sanitised$//;

                if (grep { $basetable eq $_ } NON_REPLICATED_TABLES)
                {
                        warn "Skipping non-replicated table $basetable\n";
                        next;
                }
        }

        if ($table =~ /^(.*)_sanitised$/)
        {
                my $basetable = $1;

                if (not empty($basetable))
                {
                        warn "$basetable table already contains data; skipping $table\n";
                        next;
                }

                print localtime() . " : loading $file into $basetable\n";
                ImportTable($basetable, $file) or next;

        } else {
                if (not empty($table))
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
        not($decompress) ? "cat"
        : $decompress eq "--gzip" ? "gunzip"
        : $decompress eq "--bzip2" ? "bunzip2"
        : die
    );

    print localtime() . " : Pre-checking $tar\n";
    system "$cat_cmd < $tar | head -c 102400 | tar -C $dir -xf- 2>/dev/null";

    if (open(my $fh, "<", "$dir/SCHEMA_SEQUENCE"))
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
        "INSERT INTO editor (id, name, password, ha1)
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
             WHERE editor.id IS NULL"
    );
    $sql->commit;
}

# vi: set ts=4 sw=4 :
