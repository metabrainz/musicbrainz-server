#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 9;
use_ok 'MusicBrainz::Server::Data::Collection';

use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+collection');


my $sql = Sql->new($c->dbh);
my $coll_data = MusicBrainz::Server::Data::Collection->new(c => $c);

$sql->Begin;
$coll_data->merge_releases(1, 2, 3);
$sql->Commit;

ok($coll_data->check_release(1, 1), 'Release #1 is still in collection #1');
ok(!$coll_data->check_release(1, 3), 'Release #3 has been deleted');
ok(!$coll_data->check_release(2, 2), 'Release #2 has been deleted');
ok($coll_data->check_release(2, 1), 'Release #2 has been merged into #1');
ok($coll_data->check_release(2, 4), 'Release #4 is still there');

$sql->Begin;
$coll_data->delete_releases(1, 4);
$sql->Commit;

ok(!$coll_data->check_release(1, 1), 'Release #1 has been deleted');
ok(!$coll_data->check_release(2, 1), 'Release #1 has been deleted');
ok(!$coll_data->check_release(2, 4), 'Release #4 has been deleted');
