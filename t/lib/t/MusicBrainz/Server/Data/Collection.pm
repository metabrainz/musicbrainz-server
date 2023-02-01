package t::MusicBrainz::Server::Data::Collection;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Collection;

use MusicBrainz::Server::Test qw( test_xpath_html );
use Sql;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+collection');

my $sql = $test->c->sql;
my $coll_data = MusicBrainz::Server::Data::Collection->new(c => $test->c);

my ($collections, $hits) = $coll_data->find_by_subscribed_editor(3, 10, 0);
is($hits, 0, 'Editor #3 is subscribed to no collections');

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
is($hits, 0, q(No edits found for editor #1's subscribed entities));

($edits, $hits) = $test->c->model('Edit')->subscribed_entity_edits(2, 1);
is($hits, 1, q(One available open edit found for editor #2's subscribed entities));

($edits, $hits) = $test->c->model('Edit')->subscribed_entity_edits(2, 0);
is($hits, 2, q(Two edits total found for editor #2's subscribed entities));

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

# Checking for subscription permissions for private collections
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

$mech->get_ok('/account/subscriptions/collection/add?id=7',
              'Subscribe to private collection user collaborates on');
(undef, $hits) = $coll_data->find_by_subscribed_editor(1, 10, 0);
is($hits, 2, 'Editor #1 is now subscribed to a second collection');

$mech->get('/logout');
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'editor3', password => 'pass' } );

$mech->get_ok('/account/subscriptions/collection/add?id=2',
              'Subscribe to public collection');

$mech->get('/account/subscriptions/collection/add?id=7');
is($mech->status, 403,
   'Subscription attempt to private collection was rejected');

(undef, $hits) = $coll_data->find_by_subscribed_editor(3, 10, 0);
is($hits, 1, 'Editor #3 is now subscribed to one collection');

# Checking for subscription changes when collection is made private
$mech->get('/logout');
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'editor2', password => 'pass' } );
my $collection2 = $test->c->model('Collection')->get_by_id(2);
$test->c->model('Editor')->load_for_collection($collection2);
$mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb/own_collection/edit');
$mech->form_number(2);
$mech->field('edit-list.public', 0);
$mech->click();

$collection2 = $test->c->model('Collection')->get_by_id(2);
ok(!$collection2->{public}, 'Collection is now private');

(undef, $hits) = $coll_data->find_by_subscribed_editor(3, 10, 0);
is($hits, 0, 'Editor #3 is no longer subscribed to now private collection');
(undef, $hits) = $coll_data->find_by_subscribed_editor(2, 10, 0);
is($hits, 1,
   'Editor #2 is still subscribed to now private collection they own');
(undef, $hits) = $coll_data->find_by_subscribed_editor(1, 10, 0);
is($hits, 2, 'Editor #1 is still subscribed to now private collection they collaborate on');

# Checking for subscription changes when collaborator is removed
$mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb/own_collection/edit');
$mech->form_number(2);
$mech->field('edit-list.collaborators.0.id', '');
$mech->click();

my $tx = test_xpath_html($mech->content);
$tx->is('//div[@id="content"]/div[@class="collaborators"]/p/a', '',
      'No longer contains collaborator');

(undef, $hits) = $coll_data->find_by_subscribed_editor(1, 10, 0);
is($hits, 1, 'Editor #1 is no longer subscribed to private collection they no longer collaborate on');

# Checking dropped subscriptions are restored when collection is made public
$mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb/own_collection/edit');
$mech->form_number(2);
$mech->field('edit-list.public', 1);
$mech->click();

$collection2 = $test->c->model('Collection')->get_by_id(2);
ok($collection2->{public}, 'Collection is now public again');

(undef, $hits) = $coll_data->find_by_subscribed_editor(3, 10, 0);
is($hits, 1, 'Editor #3 is subscribed to now public collection again');
(undef, $hits) = $coll_data->find_by_subscribed_editor(2, 10, 0);
is($hits, 1,
   'Editor #2 is still subscribed to now public collection they own');
(undef, $hits) = $coll_data->find_by_subscribed_editor(1, 10, 0);
is($hits, 2, 'Editor #1 is subscribed to now public collection again');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
