#!/usr/bin/perl
use strict;
use Test::More;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

BEGIN { use_ok 'MusicBrainz::Server::Data::EditorSubscriptions'; }

use aliased 'MusicBrainz::Server::Entity::EditorSubscription';

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

subtest 'get_all_subscriptions' => sub {
    my @subscriptions = $c->model('EditorSubscriptions')
        ->get_all_subscriptions(2);
    is(@subscriptions => 1, 'found one subscription');
    isa_ok($subscriptions[0] => EditorSubscription,
        'found editor subscription');
    is($subscriptions[0]->subscribed_editor_id => 1,
        'subscribed to editor 1');
};

subtest 'update_subscriptions' => sub {
    my @subscriptions = $c->model('EditorSubscriptions')
        ->get_all_subscriptions(2);
    is($subscriptions[0]->last_edit_sent, 3);

    $c->model('EditorSubscriptions')->update_subscriptions(4,
        $subscriptions[0]->editor_id);

    @subscriptions = $c->model('EditorSubscriptions')
        ->get_all_subscriptions(2);
    is($subscriptions[0]->last_edit_sent, 4);
};

done_testing;
