use strict;
use warnings;
use Test::More tests => 11;
use_ok 'MusicBrainz::Server::Data::Track';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
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
