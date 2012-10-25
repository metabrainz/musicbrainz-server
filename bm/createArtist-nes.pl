#!/usr/bin/env perl

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Time::HiRes qw( gettimeofday tv_interval );
use Text::CSV::Unicode;
use URI;
use LWP::UserAgent;
use JSON;

sub createArtist
{
    my $artist = shift;

    my $uri = URI->new ('http://localhost:8000/artist/create');

    $artist->{"api.editor"} = 1;
    $uri->query_form ($artist);

    my $ua = LWP::UserAgent->new;
    my $response = $ua->get ($uri);

    my $created = decode_json ($response->content);

    return $created;
}

sub artist_from_csv
{
    my $line = shift;

    my $csv = Text::CSV::Unicode->new();
    $csv->parse ($line);
    my @columns = $csv->fields ();

    my $artist = {
        "api.artist.name" =>              $columns[0],
        "api.artist.sort-name" =>         $columns[1],
        "api.artist.country" =>           $columns[2],
        "api.artist.gender" =>            $columns[3],
        "api.artist.comment" =>           $columns[4],
        "api.artist.ended" =>             $columns[5],
        "api.artist.begin-date.year" =>   $columns[6],
        "api.artist.begin-date.month" =>  $columns[7],
        "api.artist.begin-date.day" =>    $columns[8],
        "api.artist.end-date.year" =>     $columns[9],
        "api.artist.end-date.month" =>    $columns[10],
        "api.artist.end-date.day" =>      $columns[11],
    };

    return $artist;
}

while (<>) {
    my $artist = artist_from_csv ($_);

    my $t0 = [gettimeofday];

    my $created = createArtist ($artist);

    my $elapsed = tv_interval ($t0);  # in seconds (float)
    print "$elapsed, ".$created->{mbid}.", ".$created->{data}->{name}."\n";
};

