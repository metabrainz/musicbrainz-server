package MusicBrainz::Server::Track;
use strict;
use Carp 'confess';
use DateTime::Format::Duration;

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

    $ms or return "?:??";
    $ms >= 1000 or return "$ms ms";

    my $f = DateTime::Format::Duration->new (normalize => 1, pattern => "%H:%M:%S");
    return $f->format_duration_from_deltas (seconds => $ms / 1000);
}

sub FormatXSDTrackLength
{
    my $ms = shift;
    $ms or return undef;
    #$ms >= 1000 or return "$ms ms";
    my $length_in_secs = ($ms / 1000.0);
    sprintf "PT%dM%dS",
        int($length_in_secs / 60),
        ($length_in_secs % 60),
    ;

}

sub UnformatTrackLength
{
    my $length = shift;
    if ($length =~ /^\s*(\d{1,3}):(\d{1,2})\s*$/ && $2 < 60)
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
