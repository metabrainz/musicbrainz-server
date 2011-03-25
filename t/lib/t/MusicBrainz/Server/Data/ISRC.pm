package t::MusicBrainz::Server::Data::ISRC;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::ISRC;

use Sql;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

my $isrc = $test->c->model('ISRC')->get_by_id(1);
is($isrc->id, 1);
is($isrc->isrc, 'DEE250800230');

memory_cycle_ok($test->c->model('ISRC'));
memory_cycle_ok($isrc);

my @isrcs = $test->c->model('ISRC')->find_by_recording(1);
is(scalar @isrcs, 1);
is($isrcs[0]->isrc, 'DEE250800230');

memory_cycle_ok($test->c->model('ISRC'));
memory_cycle_ok(\@isrcs);

@isrcs = $test->c->model('ISRC')->find_by_recording(2);
is(scalar @isrcs, 2);
is($isrcs[0]->isrc, 'DEE250800230');
is($isrcs[1]->isrc, 'DEE250800231');

@isrcs = $test->c->model('ISRC')->find_by_recording([1, 2]);
is(scalar @isrcs, 3);

my $sql = $test->c->sql;
$sql->begin;
$test->c->model('ISRC')->merge_recordings(1, 2);
memory_cycle_ok($test->c->model('ISRC'));
$sql->commit;

@isrcs = $test->c->model('ISRC')->find_by_recording(1);
is(scalar @isrcs, 2);
is($isrcs[0]->isrc, 'DEE250800230');
is($isrcs[1]->isrc, 'DEE250800231');

@isrcs = $test->c->model('ISRC')->find_by_recording(2);
is(scalar @isrcs, 0);

$sql->begin;
$test->c->model('ISRC')->delete_recordings(1);
memory_cycle_ok($test->c->model('ISRC'));
$sql->commit;

@isrcs = $test->c->model('ISRC')->find_by_recording(1);
is(scalar @isrcs, 0);

$sql->begin;
$test->c->model('ISRC')->insert(
    { isrc => 'DEE250800232', recording_id => 2 }
);
memory_cycle_ok($test->c->model('ISRC'));
$sql->commit;

@isrcs = $test->c->model('ISRC')->find_by_recording(2);
is(scalar @isrcs, 1);
is($isrcs[0]->isrc, 'DEE250800232');

$sql->begin;

$test->c->model('ISRC')->delete(1);
$isrc = $test->c->model('ISRC')->get_by_id(1);
ok(!defined $isrc);

$sql->commit;

};

1;
