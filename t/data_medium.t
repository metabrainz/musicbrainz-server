use strict;
use warnings;
use Test::More tests => 21;
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
is ( $medium->name, 'The Second Disc' );
is ( $medium->format_id, 1 );

my ($results, $hits) = $medium_data->find_by_tracklist(1, 10, 0);
is( $hits, 1 );
is ( scalar @$results, 1 );
is( $results->[0]->id, 1 );
ok( defined $results->[0]->release );
is( $results->[0]->release->name, 'Arrival' );
is( $results->[0]->position, 1 );
