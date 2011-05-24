package t::MusicBrainz::Server::Data::Tracklist;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Tracklist;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Track;
use MusicBrainz::Server::Test;

with 't::Context';

test 'Track count triggers' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');

    my $sql = $test->c->sql;

    my $tc1 = $sql->select_single_value("SELECT track_count FROM tracklist WHERE id=1");
    my $tc2 = $sql->select_single_value("SELECT track_count FROM tracklist WHERE id=2");

    is ( $tc1, 7 );
    is ( $tc2, 9 );

    $sql->auto_commit(1);
    $sql->do("DELETE FROM track WHERE tracklist=1");

    $tc1 = $sql->select_single_value("SELECT track_count FROM tracklist WHERE id=1");
    $tc2 = $sql->select_single_value("SELECT track_count FROM tracklist WHERE id=2");

    is ( $tc1, 0 );
    is ( $tc2, 9 );
};

test 'Merging tracklists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, <<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, NULL);

INSERT INTO tracklist (id) VALUES (1), (2);

INSERT INTO track_name (id, name) VALUES (1, 'King of the Mountain'), (2, 'π'), (3, 'Track 3');
INSERT INTO recording (id, gid, name, artist_credit, length)
    VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 293720),
           (2, '659f405b-b4ee-4033-868a-0daa27784b89', 2, 1, 369680),
           (3, 'ae674299-2824-4500-9516-653ac1bc6f80', 3, 1, 258839);
INSERT INTO track (id, tracklist, position, recording, name, artist_credit, length) VALUES
    (1, 1, 1, 1, 1, 1, NULL), (2, 1, 2, 2, 2, 1, NULL),
    (3, 2, 1, 1, 1, 1, NULL), (4, 2, 2, 3, 2, 1, NULL);
EOSQL

    $c->model('Tracklist')->merge(1, 2);

    my $final_tl = $c->model('Tracklist')->get_by_id(1);
    $c->model('Track')->load_for_tracklists($final_tl);
    is($final_tl->tracks->[0]->id => 1);
    is($final_tl->tracks->[0]->recording_id => 1);
    is($final_tl->tracks->[1]->id => 2);
    is($final_tl->tracks->[1]->recording_id => 2);

    my $r1 = $c->model('Recording')->get_by_gid('ae674299-2824-4500-9516-653ac1bc6f80');
    is($r1->id, 2, 'merged recording 3 into recording 1');
};

test 'find_or_insert works correctly with similar tracklists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

    my $tracklist_definition = [
        {
            name => 'Track 1',
            artist_credit => 1,
            recording_id => 1,
            position => 1
        }
    ];
    my $tracklist_1 = $c->model('Tracklist')->find_or_insert($tracklist_definition);

    push @$tracklist_definition, {
        name => 'Track 2',
        artist_credit => 1,
        recording_id => 2,
        position => 2
    };

    my $tracklist_2 = $c->model('Tracklist')->find_or_insert($tracklist_definition);

    isnt($tracklist_1, $tracklist_2);
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');

my $tracklist_data = MusicBrainz::Server::Data::Tracklist->new(c => $test->c);
memory_cycle_ok($tracklist_data);

my $tracklist1 = $tracklist_data->get_by_id(1);
is ( $tracklist1->id, 1, "id" );
is ( $tracklist1->track_count, 7, "track count");
memory_cycle_ok($tracklist_data);
memory_cycle_ok($tracklist1);

my $tracklist2 = $tracklist_data->get_by_id(2);
is ( $tracklist2->id, 2, "id" );
is ( $tracklist2->track_count, 9, "track count" );

my $track_data = MusicBrainz::Server::Data::Track->new(c => $test->c);
$track_data->load_for_tracklists($tracklist1, $tracklist2);
is ( scalar($tracklist1->all_tracks), 7, "7 tracks" );
is ( $tracklist1->tracks->[0]->name, "King of the Mountain", "first track is King of the Mountain" );
is ( $tracklist1->tracks->[5]->name, "Joanni", "sixth track is Joanni" );
is ( scalar($tracklist2->all_tracks), 9, "9 tracks" );
is ( $tracklist2->tracks->[3]->name, "The Painter's Link", "fourth track is The Painter's Link" );

memory_cycle_ok($tracklist_data);
memory_cycle_ok($track_data);
memory_cycle_ok($tracklist1);

my $tracklist = $tracklist_data->find_or_insert([{
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

memory_cycle_ok($tracklist_data);
memory_cycle_ok($tracklist);

$tracklist = $tracklist_data->get_by_id($tracklist->id);
$track_data->load_for_tracklists($tracklist);
is($tracklist->track_count, 2, "Inserted a new tracklist with two tracks");
is($tracklist->all_tracks, 2);
is($tracklist->tracks->[0]->name, 'Track 1', "Track 1");
is($tracklist->tracks->[0]->position, 1, "... at position 1");
is($tracklist->tracks->[0]->artist_credit_id, 1, "... with artist_credit 1");
is($tracklist->tracks->[0]->recording_id, 1, "... with recording id 1");
is($tracklist->tracks->[1]->name, 'Track 2', "Track 2");
is($tracklist->tracks->[1]->position, 2, "... at position 2");
is($tracklist->tracks->[1]->artist_credit_id, 1, "... with artist credit 1");
is($tracklist->tracks->[1]->recording_id, 2, "... with recording id 2");

memory_cycle_ok($tracklist_data);
memory_cycle_ok($tracklist);

subtest 'Can set tracklist times via a disc id' => sub {
    Sql::run_in_transaction(sub {
        $tracklist_data->set_lengths_to_cdtoc(1, 1);
        memory_cycle_ok($tracklist_data);
    }, $test->c->sql);

    $tracklist = $tracklist_data->get_by_id(1);
    $track_data->load_for_tracklists($tracklist);
    is($tracklist->tracks->[0]->length, 338000);
    is($tracklist->tracks->[1]->length, 273000);
    is($tracklist->tracks->[2]->length, 327000);
    is($tracklist->tracks->[3]->length, 252000);
    is($tracklist->tracks->[4]->length, 719000);
    is($tracklist->tracks->[5]->length, 276000);
    is($tracklist->tracks->[6]->length, 94000);
};

my $tracks = [
    { name => 'Track 1', artist_credit => 1, recording => 1 },
    { name => 'Track 2', artist_credit => 1, recording => 2 },
    { name => 'Track 3', artist_credit => 1, recording => 3 }
];

$tracklist = $tracklist_data->find_or_insert($tracks);
memory_cycle_ok($tracklist_data);

ok($tracklist, 'returned a tracklist id');
ok($tracklist->id > 0, 'returned a tracklist id');
is($tracklist_data->find_or_insert($tracks)->id => $tracklist->id,
   'returns the same tracklist for a reinsert');
is($tracklist_data->find_or_insert($tracks)->id => $tracklist->id,
   'returns the same tracklist for a reinsert');

};

1;
