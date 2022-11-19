package MusicBrainz::Server::Track;
use strict;
use warnings;

use Carp qw( confess );
use POSIX qw( floor );
use Scalar::Util qw( looks_like_number );

use Sub::Exporter -setup => {
    exports => [
        format_track_length => sub {
            sub { FormatTrackLength(shift) }
        },
        unformat_track_length => sub {
            sub { UnformatTrackLength(shift) }
        },
        format_iso_duration => sub {
            sub { FormatTrackLength(shift, print_formats => {hms => 'PT%dH%02dM%02dS', ms => 'PT%02dM%02dS'}) }
        },
    ]
};

sub FormatTrackLength
{
    my ($ms, %opts) = @_;
    my $print_formats = $opts{print_formats} // {hms => '%d:%02d:%02d', ms => '%d:%02d'};

    return '?:??' unless $ms;
    return $ms unless looks_like_number($ms);
    return "$ms ms" if $ms < 1000;

    # Round time in ms to nearest second
    my $seconds = int(($ms / 1000.0) + 0.5);

    # Partition seconds in minutes and hours
    my $one_minute = 60;
    my $one_hour = $one_minute * 60;

    my ($hours, $minutes);
    ($hours, $seconds) = (floor($seconds / $one_hour), $seconds % $one_hour);
    ($minutes, $seconds) = (floor($seconds / $one_minute), $seconds % $one_minute);

    return $hours > 0 ?
        sprintf($print_formats->{hms}, $hours, $minutes, $seconds) :
        sprintf($print_formats->{ms}, $minutes, $seconds);
}

sub UnformatTrackLength
{
    my $length = shift;

    if ($length =~ /^\s*(\d{1,3}):(\d{1,2}):(\d{1,2})\s*$/ && $2 < 60 && $3 < 60)
    {
        return ($1 * 3600 + $2 * 60 + $3) * 1000;
    }
    elsif ($length =~ /^\s*(\d+):(\d{1,2})\s*$/ && $2 < 60)
    {
        return ($1 * 60 + $2) * 1000;
    }
    elsif ($length =~ /^\s*(\d+(\.\d+)?)?\s+ms\s*$/)
    {
        return int($1);
    }
    elsif ($length =~ /^\s*\?:\?\?\s*$/ || $length =~ /^\s*$/)
    {
        return undef;
    }
    else {
        confess("$length is not a valid track length");
    }
}

1;
