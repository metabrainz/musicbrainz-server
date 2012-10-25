#!/usr/bin/env perl

use 5.10.0;
use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use URI;
use LWP::UserAgent;
use JSON;
use Time::HiRes qw( gettimeofday tv_interval );
use Text::Trim;

sub findArtist
{
    my $uri = URI->new ('http://localhost:8000/artist/find-latest');
    $uri->query_form ({ "api.mbid" => shift });

    state $ua = LWP::UserAgent->new (keep_alive => 5);
    my $response = $ua->get ($uri);

    return undef if $response->content eq "null";

    return decode_json ($response->content);
}

while (<>) {
    my $mbid = trim $_;

    my $t0 = [gettimeofday];

    my $result = findArtist ($mbid);

    my $elapsed = tv_interval ($t0);  # in seconds (float)

    if ($result)
    {
        print "$elapsed, ".$result->{mbid}.", FOUND, ".$result->{data}->{name}."\n";
    }
    else
    {
        print "$elapsed, $mbid, NOT FOUND, \n";
    }
};
