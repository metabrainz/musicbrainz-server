use strict;
use warnings;
use Test::More tests => 25;
use_ok 'MusicBrainz::Server::Data::Artist';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);

my $artist = $artist_data->get_by_id(1);
is ( $artist->id, 1 );
is ( $artist->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $artist->name, "Artist 1" );
is ( $artist->sort_name, "Artist 1" );
is ( $artist->begin_date->year, 2008 );
is ( $artist->begin_date->month, 1 );
is ( $artist->begin_date->day, 2 );
is ( $artist->end_date->year, 2009 );
is ( $artist->end_date->month, 3 );
is ( $artist->end_date->day, 4 );
is ( $artist->edits_pending, 0 );
is ( $artist->comment, undef );

$artist = $artist_data->get_by_id(2);
is ( $artist->id, 2 );
is ( $artist->gid, "745c079d-374e-4436-9448-da92dedef3cf" );
is ( $artist->name, "The 2nd Artist" );
is ( $artist->sort_name, "2nd Artist, The" );
is ( $artist->begin_date->year, undef );
is ( $artist->begin_date->month, undef );
is ( $artist->begin_date->day, undef );
is ( $artist->end_date->year, undef );
is ( $artist->end_date->month, undef );
is ( $artist->end_date->day, undef );
is ( $artist->edits_pending, 0 );
is ( $artist->comment, undef );
