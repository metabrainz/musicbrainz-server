use strict;
use warnings;
use Test::More tests => 36;
use_ok 'MusicBrainz::Server::Data::Track';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $track_data = MusicBrainz::Server::Data::Track->new(c => $c);

my $track = $track_data->get_by_id(1);
is ( $track->id, 1 );
is ( $track->name, "Dancing Queen" );
is ( $track->recording_id, 1 );
is ( $track->artist_credit_id, 2 );
is ( $track->position, 1 );

$track = $track_data->get_by_id(2);
is ( $track->id, 2 );
is ( $track->name, "Track 2" );
is ( $track->recording_id, 1 );
is ( $track->artist_credit_id, 2 );
is ( $track->position, 2 );

my ($tracks, $hits) = $track_data->find_by_recording(2, 10);
is( $hits, 2 );
is( scalar(@$tracks), 2 );
is( $tracks->[0]->id, 4 );
is( $tracks->[0]->position, 1 );
is( $tracks->[0]->tracklist->id, 3 );
is( $tracks->[0]->tracklist->track_count, 7 );
is( $tracks->[0]->tracklist->medium->id, 3 );
is( $tracks->[0]->tracklist->medium->name, "A Sea of Honey" );
is( $tracks->[0]->tracklist->medium->position, 1 );
is( $tracks->[0]->tracklist->medium->release->id, 2 );
is( $tracks->[0]->tracklist->medium->release->date->format, "2005-11-07" );
is( $tracks->[0]->tracklist->medium->release->name, "Aerial" );
is( $tracks->[1]->id, 4 );
is( $tracks->[1]->position, 1 );
is( $tracks->[1]->tracklist->id, 3 );
is( $tracks->[1]->tracklist->track_count, 7 );
is( $tracks->[1]->tracklist->medium->id, 5 );
is( $tracks->[1]->tracklist->medium->name, "A Sea of Honey" );
is( $tracks->[1]->tracklist->medium->position, 1 );
is( $tracks->[1]->tracklist->medium->release->id, 3 );
is( $tracks->[1]->tracklist->medium->release->date->format, "2005-11-08" );
is( $tracks->[1]->tracklist->medium->release->name, "Aerial" );

my %names = $track_data->find_or_insert_names('Dancing Queen', 'Traits');
is(keys %names, 2);
is($names{'Dancing Queen'}, 1);
ok($names{'Traits'} > 19);
