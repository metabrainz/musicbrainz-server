package MusicBrainz::Script::MBDump;

use base 'Exporter';

# overrides the user-specified $keep_files
our $erase_files_on_exit = 1;
our $export_dir = '';
our $row_counts = {};

our @EXPORT_OK = qw(
    write_file
);

sub write_file {
    my ($file, $contents) = @_;

    open(my $fh, ">$export_dir/$file") or die $!;
    print $fh $contents or die $!;
    close $fh or die $!;
}

1;
