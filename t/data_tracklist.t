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
Sql::run_in_transaction(sub {
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

my $tracklist = $tracklist_data->insert([{
    name => 'Track 1',
    position => 1,
    artist_credit => 1,
    recording => 1
}, {
    name => 'Track 2',
    position => 2,
    artist_credit => 1,
    recording => 2
}]);
isa_ok($tracklist, 'MusicBrainz::Server::Entity::Tracklist');

$tracklist = $tracklist_data->get_by_id($tracklist->id);
$track_data->load_for_tracklists($tracklist);
is($tracklist->track_count, 2);
is($tracklist->all_tracks, 2);
is($tracklist->tracks->[0]->name, 'Track 1');
is($tracklist->tracks->[0]->position, 1);
is($tracklist->tracks->[0]->artist_credit_id, 1);
is($tracklist->tracks->[0]->recording_id, 1);
is($tracklist->tracks->[1]->name, 'Track 2');
is($tracklist->tracks->[1]->position, 2);
is($tracklist->tracks->[1]->artist_credit_id, 1);
is($tracklist->tracks->[1]->recording_id, 2);

done_testing;
