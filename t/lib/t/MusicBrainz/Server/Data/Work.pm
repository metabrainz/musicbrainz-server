package t::MusicBrainz::Server::Data::Work;
use Test::Routine;
use Test::More;
use Test::Memory::Cycle;

use_ok 'MusicBrainz::Server::Data::Work';
use MusicBrainz::Server::Data::WorkType;
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

my $work_data = MusicBrainz::Server::Data::Work->new(c => $test->c);
memory_cycle_ok($work_data);

my $work = $work_data->get_by_id(1);
is ( $work->id, 1 );
is ( $work->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->artist_credit_id, 1 );
is ( $work->iswc, "T-000.000.001-0" );
is ( $work->type_id, 1 );
is ( $work->edits_pending, 0 );
memory_cycle_ok($work_data);
memory_cycle_ok($work);

$work = $work_data->get_by_gid("745c079d-374e-4436-9448-da92dedef3ce");
is ( $work->id, 1 );
is ( $work->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->artist_credit_id, 1 );
is ( $work->iswc, "T-000.000.001-0" );
is ( $work->type_id, 1 );
is ( $work->edits_pending, 0 );
memory_cycle_ok($work_data);
memory_cycle_ok($work);

is ( $work->type, undef );
MusicBrainz::Server::Data::WorkType->new(c => $test->c)->load($work);
is ( $work->type->name, "Composition" );
memory_cycle_ok($work_data);
memory_cycle_ok($work);

my ($works, $hits) = $work_data->find_by_artist(1, 100);
is( $hits, 1 );
is( scalar(@$works), 1 );
is( $works->[0]->name, "Dancing Queen" );
memory_cycle_ok($work_data);
memory_cycle_ok($works);

my $annotation = $work_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );

memory_cycle_ok($work_data);
memory_cycle_ok($annotation);

$work = $work_data->get_by_gid('28e73402-5666-4d74-80ab-c3734dc699ea');
is ( $work->id, 1 );

$work = $work_data->get_by_gid('ffffffff-ffff-ffff-ffff-ffffffffffff');
is ( $work, undef );

memory_cycle_ok($work_data);
memory_cycle_ok($annotation);

my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my $results;
($results, $hits) = $search->search("work", "queen", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "Dancing Queen" );

memory_cycle_ok($results);

my %names = $work_data->find_or_insert_names('Dancing Queen', 'Traits');
is(keys %names, 2);
is($names{'Dancing Queen'}, 1);
ok($names{'Traits'} > 1);
memory_cycle_ok($work_data);
memory_cycle_ok(\%names);

$test->c->sql->begin;
$test->c->raw_sql->begin;

$work = $work_data->insert({
        name => 'Traits',
        artist_credit => 1,
        type_id => 1,
        iswc => 'T-000.000.001-0',
        comment => 'Drum & bass track',
    });
memory_cycle_ok($work_data);
memory_cycle_ok($work);

isa_ok($work, 'MusicBrainz::Server::Entity::Work');
ok($work->id > 1);

$work = $work_data->get_by_id($work->id);
is($work->name, 'Traits');
is($work->artist_credit_id, 1);
is($work->comment, 'Drum & bass track');
is($work->iswc, 'T-000.000.001-0');
is($work->type_id, 1);
ok(defined $work->gid);

$work_data->update($work->id, {
        name => 'Traits (remix)',
        iswc => 'T-100.000.001-0',
    });
memory_cycle_ok($work_data);

$work = $work_data->get_by_id($work->id);
is($work->name, 'Traits (remix)');
is($work->iswc, 'T-100.000.001-0');

$work_data->delete($work->id);
memory_cycle_ok($work_data);

$work = $work_data->get_by_id($work->id);
ok(!defined $work);

$test->c->raw_sql->commit;
$test->c->sql->commit;

# Both #1 and #2 are in the DB
$work = $work_data->get_by_id(1);
ok(defined $work);
$work = $work_data->get_by_id(2);
ok(defined $work);

# Merge #2 into #1
$test->c->sql->begin;
$test->c->raw_sql->begin;
$work_data->merge(1, 2);
memory_cycle_ok($work_data);
$test->c->sql->commit;
$test->c->raw_sql->commit;

# Only #1 is now in the DB
$work = $work_data->get_by_id(1);
ok(defined $work);
$work = $work_data->get_by_id(2);
ok(!defined $work);

};

1;
