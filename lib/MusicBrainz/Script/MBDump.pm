package MusicBrainz::Script::MBDump;

use base 'Exporter';

use DBDefs;
use MusicBrainz::Script::Utils qw( log );
use Time::HiRes qw( gettimeofday tv_interval );

# overrides the user-specified $keep_files
our $erase_files_on_exit = 1;
our $export_dir = '';
our $output_dir = '.';
our $row_counts = {};

our @EXPORT_OK = qw(
    copy_readme
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

1;
