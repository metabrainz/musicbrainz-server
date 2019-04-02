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

($edits, $hits) = $test->c->model('Edit')->subscribed_entity_edits(2, 1);
is($hits, 1, 'One available open edit found for editor #2\'s subscribed entities');

($edits, $hits) = $test->c->model('Edit')->subscribed_entity_edits(2, 0);
is($hits, 2, 'Two edits total found for editor #2\'s subscribed entities');

$test->c->model('EditorSubscriptions')->update_subscriptions(2, 2);
@subs = $test->c->model('EditorSubscriptions')->get_all_subscriptions(2);
is(scalar(@subs), 1, 'Unavailable subscription deleted');

$sql->begin;
$coll_data->merge_entities('release', 1, 2, 3);
$sql->commit;


ok($coll_data->contains_entity('release', 1, 1), 'Release #1 is still in collection #1');
ok(!$coll_data->contains_entity('release', 1, 3), 'Release #3 has been deleted');
ok(!$coll_data->contains_entity('release', 2, 2), 'Release #2 has been deleted');
ok($coll_data->contains_entity('release', 2, 1), 'Release #2 has been merged into #1');
ok($coll_data->contains_entity('release', 2, 4), 'Release #4 is still there');


$sql->begin;
$coll_data->delete_entities('release', 1, 4);
$sql->commit;


ok(!$coll_data->contains_entity('release', 1, 1), 'Release #1 has been deleted');
ok(!$coll_data->contains_entity('release', 2, 1), 'Release #1 has been deleted');
ok(!$coll_data->contains_entity('release', 2, 4), 'Release #4 has been deleted');

$coll_data->add_entities_to_collection('release', 1, 3);
ok($coll_data->contains_entity('release', 1, 3), 'Release #3 has been added to collection #1');

$coll_data->add_entities_to_collection('release', 1, 3);
ok($coll_data->contains_entity('release', 1, 3), 'No exception occurred when re-adding release #3');


my ($releases) = $coll_data->find_by({ entity_type => 'release', entity_id => 3, show_private => 1 });
is(scalar(@$releases), 1, 'One collection contains release #3');
ok((grep { $_->id == 1 } @$releases), 'found collection by release');

ok(!$coll_data->contains_entity('event', 3, 1), 'Event #1 is not in collection #3');
$coll_data->add_entities_to_collection('event', 3, 1);
ok($coll_data->contains_entity('event', 3, 1), 'Now event #1 is in collection #3');

$sql->begin;
$coll_data->merge_entities('event', 2, 3);
$sql->commit;

ok(!$coll_data->contains_entity('event', 4, 3), 'Event #3 has been merged and is no longer in collection #4');
ok($coll_data->contains_entity('event', 3, 2), 'Event #2 is still in collection #3');
ok($coll_data->contains_entity('event', 4, 2), 'Event #2 is now in collection #4');

my ($events) = $coll_data->find_by({ entity_type => 'event', entity_id => 2, show_private => 1 });
is(scalar(@$events), 2, 'Two collections contain event #2');
ok((grep { $_->id == 4 } @$events), 'Collection #4 is one of the ones containing event #2');
ok((grep { $_->id == 3 } @$events), 'Collection #3 is one of the ones containing event #2');

$coll_data->remove_entities_from_collection('event', 3, (1,2));
ok(!$coll_data->contains_entity('event', 3, 1), 'Event #1 is out of collection #3 again');
ok(!$coll_data->contains_entity('event', 3, 2), 'Neither is event #2 in collection #3 anymore');

ok($coll_data->contains_entity('event', 3, 4), 'Event #4 in collection #3.');
$coll_data->delete_entities('event', 4);
ok(!$coll_data->contains_entity('event', 3, 4), 'Now Event #4 is not in collection #3.');

ok($coll_data->contains_entity('work', 5, 1), 'Work #1 is in collection #5');

};

1;
