package t::MusicBrainz::Server::Data::PUID;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use_ok 'MusicBrainz::Server::Data::PUID';
use_ok 'MusicBrainz::Server::Data::RecordingPUID';

use Sql;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+puid');

my $puid_data = $test->c->model('PUID');
my $rec_puid_data = $test->c->model('RecordingPUID');
memory_cycle_ok($puid_data);

my $puid = $puid_data->get_by_id(1);
is($puid->id, 1);
is($puid->puid, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puid->client_version, 'mb_client/1.0');
memory_cycle_ok($puid_data);
memory_cycle_ok($puid);

$puid = $puid_data->get_by_puid('b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puid->id, 1);
is($puid->puid, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puid->client_version, 'mb_client/1.0');
memory_cycle_ok($puid_data);
memory_cycle_ok($puid);

my @puids = $rec_puid_data->find_by_recording(1);
is(scalar @puids, 2);
is($puids[0]->puid->puid, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puids[1]->puid->puid, '134478d1-306e-41a1-8b37-ff525e53c8be');
memory_cycle_ok($rec_puid_data);
memory_cycle_ok(\@puids);

@puids = $rec_puid_data->find_by_recording(2);
is(scalar @puids, 2);
is($puids[0]->puid->puid, '134478d1-306e-41a1-8b37-ff525e53c8be');
is($puids[1]->puid->puid, 'be42c064-91ba-4e0d-8841-085fb9ab8b17');

my $sql = $test->c->sql;
$sql->begin;
$rec_puid_data->merge_recordings(1, 2);
memory_cycle_ok($rec_puid_data);
$sql->commit;

@puids = $rec_puid_data->find_by_recording(1);
is(scalar @puids, 3);
is($puids[0]->puid->puid, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puids[1]->puid->puid, '134478d1-306e-41a1-8b37-ff525e53c8be');
is($puids[2]->puid->puid, 'be42c064-91ba-4e0d-8841-085fb9ab8b17');

@puids = $rec_puid_data->find_by_recording(2);
is(scalar @puids, 0);

$sql->begin;
$rec_puid_data->delete_recordings(1);
memory_cycle_ok($rec_puid_data);
$sql->commit;

@puids = $rec_puid_data->find_by_recording(1);
is(scalar @puids, 0);

my $cnt = $sql->select_single_value('SELECT count(*) FROM puid WHERE id IN (1,2,3)');
is($cnt, 1);

@puids = $rec_puid_data->find_by_recording(3);
is(scalar @puids, 2);
is($puids[0]->puid->puid, '5226b265-0ba5-4679-98e4-427e72b5b8cf');
is($puids[1]->puid->puid, '134478d1-306e-41a1-8b37-ff525e53c8be');

Sql::run_in_transaction(sub {
    $rec_puid_data->delete($puids[0]->puid_id, $puids[0]->id, 3);
}, $sql);

@puids = $rec_puid_data->find_by_recording(3);
is(scalar @puids, 1);
is($puids[0]->puid->puid, '134478d1-306e-41a1-8b37-ff525e53c8be');

};

1;
