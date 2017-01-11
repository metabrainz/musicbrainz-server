package MusicBrainz::Script::Utils;

use base 'Exporter';

our @EXPORT_OK = qw( log );

=sub log

Log a message to stdout, prefixed with the local time and ending with a
newline.

=cut

sub log($) {
    print localtime . ' : ' . $_[0] . "\n";
}

1;
