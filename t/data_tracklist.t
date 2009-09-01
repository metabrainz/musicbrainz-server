use strict;
use warnings;
use Test::More;
use_ok 'MusicBrainz::Server::Data::Tracklist';
use MusicBrainz::Server::Data::Track;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

my $tracklist_data = MusicBrainz::Server::Data::Tracklist->new(c => $c);

my $tracklist1 = $tracklist_data->get_by_id(1);
is ( $tracklist1->id, 1 );
is ( $tracklist1->track_count, 7 );

my $tracklist2 = $tracklist_data->get_by_id(2);
is ( $tracklist2->id, 2 );
is ( $tracklist2->track_count, 9 );

my $track_data = MusicBrainz::Server::Data::Track->new(c => $c);
$track_data->load_for_tracklists($tracklist1, $tracklist2);
is ( scalar($tracklist1->all_tracks), 7 );
is ( $tracklist1->tracks->[0]->name, "King of the Mountain" );
is ( $tracklist1->tracks->[5]->name, "Joanni" );
is ( scalar($tracklist2->all_tracks), 9 );
is ( $tracklist2->tracks->[3]->name, "The Painter's Link" );

my $sql = Sql->new($c->dbh);
Sql::RunInTransaction(sub {
    $tracklist_data->offset_track_positions(1, 4, 1);
    $tracklist1 = $tracklist_data->get_by_id(1);
    is ( $tracklist1->id, 1 );
    is ( $tracklist1->track_count, 7 );

    $track_data->load_for_tracklists($tracklist1);
    is($tracklist1->tracks->[0]->position, 1);
    is($tracklist1->tracks->[1]->position, 2);
    is($tracklist1->tracks->[2]->position, 3);
    is($tracklist1->tracks->[3]->position, 5);
    is($tracklist1->tracks->[4]->position, 6);
    is($tracklist1->tracks->[5]->position, 7);
    is($tracklist1->tracks->[6]->position, 8);
}, $sql);

done_testing;
