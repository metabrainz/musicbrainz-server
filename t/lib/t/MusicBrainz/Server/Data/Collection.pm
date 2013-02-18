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

my ($collections, $hits) = $coll_data->find_by_subscribed_editor(1, 10, 0);
is($hits, 0, 'Editor #1 is subscribed to no collections');

($collections, $hits) = $coll_data->find_by_subscribed_editor(2, 10, 0);
is($hits, 1, 'Editor #2 is subscribed to one available collection');
ok((grep { $_->id == 2 } @$collections), 'Editor #2 is subscribed to collection #2');

(my $edits, $hits) = $test->c->model('Edit')->find_by_collection(1, 10, 0);
is($hits, 1, 'All edits found for collection #1');

($edits, $hits) = $test->c->model('Edit')->find_by_collection(2, 10, 0);
is($hits, 2, 'All edits found for collection #2');

my @subs = $test->c->model('EditorSubscriptions')->get_all_subscriptions(2);
is(scalar(@subs), 2, 'Two subscriptions found for editor #2');

my ($deleted_sub) = grep { !($_->available) } @subs;
my @edit_list = $test->c->model('Edit')->find_for_subscription($deleted_sub);
is(scalar(@edit_list), 0, 'No edits found for subscription #1');

my ($sub) = grep { $_->available } @subs;
@edit_list = $test->c->model('Edit')->find_for_subscription($sub);
is(scalar(@edit_list), 2, 'All edits found for subscription #2');

($edits, $hits) = $test->c->model('Edit')->subscribed_entity_edits(1);
is($hits, 0, 'No edits found for editor #1\'s subscribed entities');

($edits, $hits) = $test->c->model('Edit')->subscribed_entity_edits(2);
is($hits, 1, 'One available open edit found for editor #2\'s subscribed entities');

$test->c->model('EditorSubscriptions')->update_subscriptions(2, 2);
@subs = $test->c->model('EditorSubscriptions')->get_all_subscriptions(2);
is(scalar(@subs), 1, 'Unavailable subscription deleted');

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
