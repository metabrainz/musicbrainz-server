package t::MusicBrainz::Server::Data::Recording;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Recording;
use MusicBrainz::Server::Data::Search;
use encoding 'utf8';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
MusicBrainz::Server::Test->prepare_test_database($test->c, '+recording');

my $rec_data = MusicBrainz::Server::Data::Recording->new(c => $test->c);
memory_cycle_ok($rec_data);

my $rec = $rec_data->get_by_id(1);
is ( $rec->id, 1 );
is ( $rec->gid, "54b9d183-7dab-42ba-94a3-7388a66604b8" );
is ( $rec->name, "King of the Mountain" );
is ( $rec->artist_credit_id, 1 );
is ( $rec->length, 293720 );
is ( $rec->edits_pending, 0 );
memory_cycle_ok($rec_data);
memory_cycle_ok($rec);

$rec = $rec_data->get_by_gid("54b9d183-7dab-42ba-94a3-7388a66604b8");
is ( $rec->id, 1 );
is ( $rec->gid, "54b9d183-7dab-42ba-94a3-7388a66604b8" );
is ( $rec->name, "King of the Mountain" );
is ( $rec->artist_credit_id, 1 );
is ( $rec->length, 293720 );
is ( $rec->edits_pending, 0 );
memory_cycle_ok($rec_data);
memory_cycle_ok($rec);

my ($recs, $hits) = $rec_data->find_by_artist(1, 100);
is( $hits, 16 );
is( scalar(@$recs), 16 );
is( $recs->[0]->name, "A Coral Room" );
is( $recs->[1]->name, "Aerial" );
is( $recs->[14]->name, "The Painter's Link" );
is( $recs->[15]->name, "π" );
memory_cycle_ok($rec_data);
memory_cycle_ok($recs);

my $annotation = $rec_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );

memory_cycle_ok($rec_data);
memory_cycle_ok($annotation);

$rec = $rec_data->get_by_gid('0986e67c-6b7a-40b7-b4ba-c9d7583d6426');
is ( $rec->id, 1 );

my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my $results;
($results, $hits) = $search->search("recording", "coral", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "A Coral Room" );

memory_cycle_ok($rec_data);
memory_cycle_ok($results);

$test->c->sql->begin;
$test->c->raw_sql->begin;

$rec = $rec_data->insert({
        name => 'Traits',
        artist_credit => 1,
        comment => 'Drum & bass track',
    });
isa_ok($rec, 'MusicBrainz::Server::Entity::Recording');
ok($rec->id > 16);
memory_cycle_ok($rec_data);
memory_cycle_ok($rec);

$rec = $rec_data->get_by_id($rec->id);
is($rec->name, 'Traits');
is($rec->artist_credit_id, 1);
is($rec->comment, 'Drum & bass track');
ok(defined $rec->gid);

$rec_data->update($rec->id, {
        name => 'Traits (remix)',
        comment => 'New remix',
    });
memory_cycle_ok($rec_data);

$rec = $rec_data->get_by_id($rec->id);
is($rec->name, 'Traits (remix)');
is($rec->comment, 'New remix');

$rec_data->delete($rec->id);
memory_cycle_ok($rec_data);
$rec = $rec_data->get_by_id($rec->id);
ok(!defined $rec);

$test->c->sql->commit;
$test->c->raw_sql->commit;

# Both #1 and #2 are in the DB
$rec = $rec_data->get_by_id(1);
ok(defined $rec);
$rec = $rec_data->get_by_id(2);
ok(defined $rec);

# Merge #2 into #1
$test->c->sql->begin;
$test->c->raw_sql->begin;
$rec_data->merge(1, 2);
memory_cycle_ok($rec_data);
$test->c->sql->commit;
$test->c->raw_sql->commit;

# Only #1 is now in the DB
$rec = $rec_data->get_by_id(1);
ok(defined $rec);
$rec = $rec_data->get_by_id(2);
ok(!defined $rec);

my @entities = map { $rec_data->get_by_id($_) } qw(1 8 14);

my %appears = $rec_data->appears_on (2, @entities);
$results = $appears{1}->{results};

is ($appears{8}->{results}->[0]->name, "Aerial", "recording 8 appears on Aerial");
is ($appears{1}->{hits}, 4, "recording 1 appears on four release groups");
is (scalar @$results, 2, " ... of which two have been returned");
is ($results->[0]->name, "Aerial", "recording 1 appears on Aerial");
is ($results->[1]->name, "エアリアル", "recording 1 appears on エアリアル");

};

1;
