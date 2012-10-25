#!/usr/bin/env perl

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Sql;
use MusicBrainz::Server;
use Time::HiRes qw( gettimeofday tv_interval );
use Text::CSV::Unicode;

my $c = MusicBrainz::Server::Context->create_script_context();

sub createArtist
{
    my $artist = shift;
    my $created;

    Sql::run_in_transaction(
        sub {
            $created = $c->model('Artist')->insert ($artist);
        },
        $c->sql);

    return $created;
}

sub artist_from_csv
{
    my $line = shift;

    my $csv = Text::CSV::Unicode->new();
    $csv->parse ($line);
    my @columns = $csv->fields ();

    my $artist = {
        name =>              $columns[0],
        sort_name =>         $columns[1],
        country =>           $columns[2],
        gender =>            $columns[3],
        comment =>           $columns[4],
        ended =>             $columns[5],
        begin_date => {
            year =>          $columns[6],
            month =>         $columns[7],
            day =>           $columns[8],
        },
        end_date => {
            year =>          $columns[9],
            month =>         $columns[10],
            day =>           $columns[11],
        },
        ipi_codes => [ ],
    };

    return $artist;
}

while (<>) {
    my $artist = artist_from_csv ($_);

    my $t0 = [gettimeofday];

    my $created = createArtist ($artist);

    my $elapsed = tv_interval ($t0);  # in seconds (float)
    print "$elapsed, ".$created->gid.", ".$created->name."\n";
};


