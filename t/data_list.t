#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use_ok 'MusicBrainz::Server::Data::List';

use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+list');


my $sql = Sql->new($c->dbh);
my $coll_data = MusicBrainz::Server::Data::List->new(c => $c);

$sql->begin;
$coll_data->merge_releases(1, 2, 3);
$sql->commit;

ok($coll_data->check_release(1, 1), 'Release #1 is still in list #1');
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

$coll_data->add_releases_to_list (1, 3);
ok($coll_data->check_release(1, 3), 'Release #3 has been added to list #1');

$coll_data->add_releases_to_list (1, 3);
ok($coll_data->check_release(1, 3), 'No exception occured when re-adding release #3');

done_testing;
