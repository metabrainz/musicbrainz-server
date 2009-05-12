use strict;
use warnings;
use Test::More tests => 15;
use_ok 'MusicBrainz::Server::Data::Medium';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $medium_data = MusicBrainz::Server::Data::Medium->new(c => $c);

my $medium = $medium_data->get_by_id(1);
is ( $medium->id, 1 );
is ( $medium->tracklist_id, 1 );
is ( $medium->tracklist->track_count, 2 );
is ( $medium->release_id, 1 );
is ( $medium->position, 1 );
is ( $medium->name, "The First Disc" );
is ( $medium->format_id, 1 );

$medium = $medium_data->get_by_id(2);
is ( $medium->id, 2 );
is ( $medium->tracklist_id, 2 );
is ( $medium->tracklist->track_count, 1 );
is ( $medium->release_id, 1 );
is ( $medium->position, 2 );
is ( $medium->name, undef );
is ( $medium->format_id, 1 );
