#!/usr/bin/env perl

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Sql;
use MusicBrainz::Server;
use Time::HiRes qw( gettimeofday tv_interval );
use Text::Trim;

my $c = MusicBrainz::Server::Context->create_script_context();

sub findArtist
{
    return $c->model('Artist')->get_by_gid (shift);
}

while (<>) {
    my $mbid = trim $_;

    my $t0 = [gettimeofday];

    my $result = findArtist ($mbid);

    my $elapsed = tv_interval ($t0);  # in seconds (float)

    if ($result)
    {
        print "$elapsed, ".$result->gid.", FOUND, ".$result->name."\n";
    }
    else
    {
        print "$elapsed, $mbid, NOT FOUND, \n";
    }
};
