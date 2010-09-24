package MusicBrainz::Server::Track;
use strict;

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

    my $length_in_secs = int($ms / 1000.0 + 0.5);
    sprintf "%d:%02d",
        int($length_in_secs / 60),
        ($length_in_secs % 60),
        ;
}

sub FormatXSDTrackLength
{
    my $ms = shift;
    $ms or return undef;
    $ms >= 1000 or return "$ms ms";
    my $length_in_secs = int($ms / 1000.0 + 0.5);
    sprintf "P%dM%dS", 
        int($length_in_secs / 60),
        ($length_in_secs % 60),
    ;
    
}

sub UnformatTrackLength
{
    my $length = shift;
    my $ms = -1;
    
    if ($length =~ /^\s*\?:\?\?\s*$/)
    {
        $ms = 0;
    }
    elsif ($length =~ /^\s*(\d{1,3}):(\d{1,2})\s*$/ && $2 < 60)
    {
        $ms = ($1 * 60 + $2) * 1000;
    }
    elsif ($length =~ /^\s*(\d+)\s+ms\s*$/)
    {
        $ms = $1;
    }
    else
    {
        $ms = -1;
    }
    
    return $ms;

}

1;
# eof Track.pm
