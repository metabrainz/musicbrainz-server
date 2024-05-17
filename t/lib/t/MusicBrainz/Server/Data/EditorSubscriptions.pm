package t::MusicBrainz::Server::Data::EditorSubscriptions;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

BEGIN { use MusicBrainz::Server::Data::EditorSubscriptions; }

use aliased 'MusicBrainz::Server::Entity::EditorSubscription';

with 't::Context';

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

subtest 'get_all_subscriptions' => sub {
    my @subscriptions = $test->c->model('EditorSubscriptions')
        ->get_all_subscriptions(2);
    is(@subscriptions => 1, 'found one subscription');
    isa_ok($subscriptions[0] => EditorSubscription,
        'found editor subscription');
    is($subscriptions[0]->subscribed_editor_id => 1,
        'subscribed to editor 1');

};

subtest 'update_subscriptions' => sub {
    my @subscriptions = $test->c->model('EditorSubscriptions')
        ->get_all_subscriptions(2);
    is($subscriptions[0]->last_edit_sent, 3);

    $test->c->model('EditorSubscriptions')->update_subscriptions(4,
        $subscriptions[0]->editor_id);

    @subscriptions = $test->c->model('EditorSubscriptions')
        ->get_all_subscriptions(2);
    is($subscriptions[0]->last_edit_sent, 4);

};

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
