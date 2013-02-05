package MusicBrainz::Server::Track;
use strict;
use Carp 'confess';
use POSIX qw( floor );
use Scalar::Util qw( looks_like_number );

use Sub::Exporter -setup => {
    exports => [
        format_track_length => sub {
            sub { FormatTrackLength(shift) }
        },
        unformat_track_length => sub {
            sub { UnformatTrackLength(shift) }
        }
    ]
};

sub FormatTrackLength
{
    my $ms = shift;

    return "?:??" unless $ms;
    return $ms unless looks_like_number($ms);
    return "$ms ms" if $ms < 1000;

    my $one_second = 1000.0;
    my $one_minute = $one_second * 60;
    my $one_hour = $one_minute * 60;

    my ($hours, $minutes, $seconds);
    ($hours, $ms) = (floor($ms / $one_hour), $ms % $one_hour);
    ($minutes, $ms) = (floor($ms / $one_minute), $ms % $one_minute);
    $seconds = int(($ms / $one_second) + 0.5);

    return $hours > 0 ?
        sprintf ("%d:%02d:%02d", $hours, $minutes, $seconds) :
        sprintf ("%d:%02d", $minutes, $seconds);
}

sub FormatXSDTrackLength
{
    my $ms = shift;
    return undef unless $ms;

    my $length_in_secs = ($ms / 1000.0 + 0.5);
    sprintf "PT%dM%dS",
        int($length_in_secs / 60),
        ($length_in_secs % 60),
    ;

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
    elsif ($length =~ /^\s*(\d+)\s+ms\s*$/)
    {
        return $1;
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
# eof Track.pm
