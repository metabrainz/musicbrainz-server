package MusicBrainz::Script::Utils;

use base 'Exporter';

our @EXPORT_OK = qw( log retry );

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
            $error = $@;
            return @result unless $error;
        } else {
            my $result = eval { $callback->() };
            $error = $@;
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
