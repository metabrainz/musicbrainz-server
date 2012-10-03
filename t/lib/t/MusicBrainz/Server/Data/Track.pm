package t::MusicBrainz::Server::Data::Track;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Track;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
$test->c->sql->do('UPDATE release SET edits_pending = 2 WHERE id = 2');

my $track_data = MusicBrainz::Server::Data::Track->new(c => $test->c);

my $track = $track_data->get_by_id(1);
is ( $track->id, 1 );
is ( $track->name, "King of the Mountain" );
is ( $track->recording_id, 1 );
is ( $track->artist_credit_id, 1 );
is ( $track->position, 1 );

$track = $track_data->get_by_id(3);
is ( $track->id, 3 );
is ( $track->name, "Bertie" );
is ( $track->recording_id, 3 );
is ( $track->artist_credit_id, 1 );
is ( $track->position, 3 );

ok( !$track_data->load() );

my ($tracks, $hits) = $track_data->find_by_recording(1, 10, 0);
is( $hits, 2 );
is( scalar(@$tracks), 2 );
is( $tracks->[0]->id, 1 );
is( $tracks->[0]->position, 1 );
is( $tracks->[0]->tracklist->id, 1 );
is( $tracks->[0]->tracklist->track_count, 7 );
is( $tracks->[0]->tracklist->medium->id, 1 );
is( $tracks->[0]->tracklist->medium->name, "A Sea of Honey" );
is( $tracks->[0]->tracklist->medium->position, 1 );
is( $tracks->[0]->tracklist->medium->release->id, 1 );
is( $tracks->[0]->tracklist->medium->release->name, "Aerial" );
is( $tracks->[1]->id, 1 );
is( $tracks->[1]->position, 1 );
is( $tracks->[1]->tracklist->id, 1 );
is( $tracks->[1]->tracklist->track_count, 7 );
is( $tracks->[1]->tracklist->medium->id, 3 );
is( $tracks->[1]->tracklist->medium->name, "A Sea of Honey" );
is( $tracks->[1]->tracklist->medium->position, 1 );
is( $tracks->[1]->tracklist->medium->release->id, 2 );
is( $tracks->[1]->tracklist->medium->release->edits_pending, 2 );
is( $tracks->[1]->tracklist->medium->release->name, "Aerial" );

my %names = $track_data->find_or_insert_names('Nocturn', 'Traits');
is(keys %names, 2);
is($names{'Nocturn'}, 15);
ok($names{'Traits'} > 16);

$track = $track_data->insert({
    tracklist_id => 1,
    recording_id => 2,
    name => 'Test track!',
    artist_credit => 1,
    length => 500,
    position => 8,
    number => 8
});

ok(defined $track);
ok($track->id > 0);

$track = $track_data->get_by_id($track->id);
is($track->position, 8);
is($track->tracklist_id, 1);
is($track->artist_credit_id, 1);
is($track->recording_id, 2);
is($track->length, 500);
is($track->name, "Test track!");

Sql::run_in_transaction(sub {
    $track_data->delete($track->id);
    $track = $track_data->get_by_id($track->id);
    ok(!defined $track);
}, $test->c->sql);

};

1;
