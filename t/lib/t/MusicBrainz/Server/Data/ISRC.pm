package t::MusicBrainz::Server::Data::ISRC;
use Test::Routine;
use Test::Moose;
use Test::More;

use_ok 'MusicBrainz::Server::Data::ISRC';

use Sql;
use MusicBrainz::Server::Test;

test all => sub {

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+isrc');

my $isrc = $c->model('ISRC')->get_by_id(1);
is($isrc->id, 1);
is($isrc->isrc, 'DEE250800230');

my @isrcs = $c->model('ISRC')->find_by_recording(1);
is(scalar @isrcs, 1);
is($isrcs[0]->isrc, 'DEE250800230');

@isrcs = $c->model('ISRC')->find_by_recording(2);
is(scalar @isrcs, 2);
is($isrcs[0]->isrc, 'DEE250800230');
is($isrcs[1]->isrc, 'DEE250800231');

@isrcs = $c->model('ISRC')->find_by_recording([1, 2]);
is(scalar @isrcs, 3);

my $sql = Sql->new($c->dbh);
$sql->begin;
$c->model('ISRC')->merge_recordings(1, 2);
$sql->commit;

@isrcs = $c->model('ISRC')->find_by_recording(1);
is(scalar @isrcs, 2);
is($isrcs[0]->isrc, 'DEE250800230');
is($isrcs[1]->isrc, 'DEE250800231');

@isrcs = $c->model('ISRC')->find_by_recording(2);
is(scalar @isrcs, 0);

$sql->begin;
$c->model('ISRC')->delete_recordings(1);
$sql->commit;

@isrcs = $c->model('ISRC')->find_by_recording(1);
is(scalar @isrcs, 0);

$sql->begin;
$c->model('ISRC')->insert(
    { isrc => 'DEE250800232', recording_id => 2 }
);
$sql->commit;

@isrcs = $c->model('ISRC')->find_by_recording(2);
is(scalar @isrcs, 1);
is($isrcs[0]->isrc, 'DEE250800232');

$sql->begin;

$c->model('ISRC')->delete(1);
$isrc = $c->model('ISRC')->get_by_id(1);
ok(!defined $isrc);

$sql->commit;

};

1;
