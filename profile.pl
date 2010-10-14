use strict;
use warnings;
use MusicBrainz::WWW::Mechanize;

my $mech = MusicBrainz::WWW::Mechanize->new( catalyst_app => 'MusicBrainz::Server' );

my $profile = 'http://127.0.0.1:3000/release/3cd97a2d-f038-4468-aee2-e6464df3eb8d';

# Prime the caches
$mech->get($profile);

DB::enable_profile();
$mech->get($profile)
    for 1..30;
DB::disable_profile();
