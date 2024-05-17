#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use MusicBrainz::WWW::Mechanize;

my $mech = MusicBrainz::WWW::Mechanize->new( catalyst_app => 'MusicBrainz::Server' );

my $profile = 'http://127.0.0.1:3000' . join('',@ARGV);

print "Profiling $profile\n";

# Prime the caches
$mech->get($profile) for 1..1;

DB::enable_profile();
$mech->get($profile)
    for 1..30;
DB::disable_profile();

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
