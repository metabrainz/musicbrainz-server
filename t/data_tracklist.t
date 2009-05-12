use strict;
use warnings;
use Test::More tests => 10;
use_ok 'MusicBrainz::Server::Data::Tracklist';
use MusicBrainz::Server::Data::Track;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $tracklist_data = MusicBrainz::Server::Data::Tracklist->new(c => $c);

my $tracklist1 = $tracklist_data->get_by_id(1);
is ( $tracklist1->id, 1 );
is ( $tracklist1->track_count, 2 );

my $tracklist2 = $tracklist_data->get_by_id(2);
is ( $tracklist2->id, 2 );
is ( $tracklist2->track_count, 1 );

my $track_data = MusicBrainz::Server::Data::Track->new(c => $c);
$track_data->load($tracklist1, $tracklist2);
is ( scalar($tracklist1->all_tracks), 2 );
is ( $tracklist1->tracks->[0]->name, "Dancing Queen" );
is ( $tracklist1->tracks->[1]->name, "Track 2" );
is ( scalar($tracklist2->all_tracks), 1 );
is ( $tracklist2->tracks->[0]->name, "Track 3" );
