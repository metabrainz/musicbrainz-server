package t::MusicBrainz::Server::Data::PUID;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::PUID;
use MusicBrainz::Server::Data::RecordingPUID;

use Sql;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+puid');

my $puid_data = $test->c->model('PUID');
my $rec_puid_data = $test->c->model('RecordingPUID');

my $puid = $puid_data->get_by_id(1);
is($puid->id, 1);
is($puid->puid, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puid->client_version, 'mb_client/1.0');

$puid = $puid_data->get_by_puid('b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puid->id, 1);
is($puid->puid, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puid->client_version, 'mb_client/1.0');

my @puids = $rec_puid_data->find_by_recording(1);
is(scalar @puids, 2);
is($puids[0]->puid->puid, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($puids[1]->puid->puid, '134478d1-306e-41a1-8b37-ff525e53c8be');

@puids = $rec_puid_data->find_by_recording(2);
is(scalar @puids, 2);
is($puids[0]->puid->puid, '134478d1-306e-41a1-8b37-ff525e53c8be');
is($puids[1]->puid->puid, 'be42c064-91ba-4e0d-8841-085fb9ab8b17');

my $sql = $test->c->sql;
$sql->begin;
$rec_puid_data->merge_recordings(1, 2);
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

test 'Merging recording puids' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, <<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '5f9913b0-7219-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, '');

INSERT INTO track_name (id, name) VALUES (1, 'Merge Me');
INSERT INTO recording (id, gid, name, artist_credit) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1),
    (2, '845c079d-374e-4436-9448-da92dedef3ce', 1, 1),
    (3, '7c43d625-c41f-46f4-ace4-6997b34c9b73', 1, 1);

INSERT INTO clientversion (id, version) VALUES (1, 'mb_client/1.0');
INSERT INTO puid (id, puid, version) VALUES
    (1, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', 1),
    (2, '134478d1-306e-41a1-8b37-ff525e53c8be', 1);

INSERT INTO recording_puid (id, recording, puid) VALUES
    (1, 1, 1),
    (2, 2, 2),
    (3, 3, 2);
EOSQL

    $test->c->model('RecordingPUID')->merge_recordings(1, 2, 3);
    my @puids = $test->c->model('RecordingPUID')->find_by_recording(1);
    is(@puids => 2, 'has 2 puids');
    ok((grep { $_->puid_id == 2 } @puids), 'has puid id 2');
    ok((grep { $_->puid_id == 1 } @puids), 'has puid id 1');
};

1;
