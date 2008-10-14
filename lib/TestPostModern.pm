use MusicBrainz::PostModern::Artist;

my $art_of_noise = MusicBrainz::PostModern::Artist->load(20);

use Data::Dumper; print Dumper $art_of_noise;
use Data::Dumper; print Dumper $art_of_noise->releases;
