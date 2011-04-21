#!/usr/bin/perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use MusicBrainz::WWW::Mechanize;

my $mech = MusicBrainz::WWW::Mechanize->new( catalyst_app => 'MusicBrainz::Server' );

my $profile = 'http://127.0.0.1:3000' . join('',@ARGV);

print "Profiling $profile\n";

# Prime the caches
$mech->get($profile) for 1..5;

DB::enable_profile();
$mech->get($profile)
    for 1..30;
DB::disable_profile();
