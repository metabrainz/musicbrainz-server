package MusicBrainz::Script::MBDump;

use base 'Exporter';

use DBDefs;

# overrides the user-specified $keep_files
our $erase_files_on_exit = 1;
our $export_dir = '';
our $row_counts = {};

our @EXPORT_OK = qw(
    copy_readme
    gpg_sign
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

sub write_file {
    my ($file, $contents) = @_;

    open(my $fh, ">$export_dir/$file") or die $!;
    print $fh $contents or die $!;
    close $fh or die $!;
}

1;
