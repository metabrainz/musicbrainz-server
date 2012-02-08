package t::MusicBrainz::Server::Data::Collection;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Collection;

use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+collection');

my $sql = $test->c->sql;
my $coll_data = MusicBrainz::Server::Data::Collection->new(c => $test->c);

$sql->begin;
$coll_data->merge_releases(1, 2, 3);
$sql->commit;


ok($coll_data->check_release(1, 1), 'Release #1 is still in collection #1');
ok(!$coll_data->check_release(1, 3), 'Release #3 has been deleted');
ok(!$coll_data->check_release(2, 2), 'Release #2 has been deleted');
ok($coll_data->check_release(2, 1), 'Release #2 has been merged into #1');
ok($coll_data->check_release(2, 4), 'Release #4 is still there');


$sql->begin;
$coll_data->delete_releases(1, 4);
$sql->commit;


ok(!$coll_data->check_release(1, 1), 'Release #1 has been deleted');
ok(!$coll_data->check_release(2, 1), 'Release #1 has been deleted');
ok(!$coll_data->check_release(2, 4), 'Release #4 has been deleted');

$coll_data->add_releases_to_collection (1, 3);
ok($coll_data->check_release(1, 3), 'Release #3 has been added to collection #1');

$coll_data->add_releases_to_collection (1, 3);
ok($coll_data->check_release(1, 3), 'No exception occured when re-adding release #3');


my @releases = $coll_data->find_all_by_release(3);
is(scalar(@releases), 1);
ok((grep { $_->id == 1 } @releases), 'found collection by release');


};

1;
