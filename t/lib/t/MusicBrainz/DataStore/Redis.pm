package t::MusicBrainz::DataStore::Redis;

use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::DataStore::Redis;
use DBDefs;

with 't::Context';

=head2 Test description

This test checks basic tasks for the Redis store, including adding, deleting
and expiring keys.

=cut

# Initialize tests
my $args = DBDefs->DATASTORE_REDIS_ARGS;
$args->{database} = $args->{test_database};
my $redis = MusicBrainz::DataStore::Redis->new(%$args);

test 'Database is still selected in new Redis copy' => sub {
    my $some_value = rand();
    $redis->set('26fe2bfb-73dd-4660-8946-bd14c899163b', $some_value);

    # The above commands have set a known value in the test database.
    # Now initialize another copy of Redis->new and have it call
    # select(), and verify that our value is still there.
    my $redis2 = MusicBrainz::DataStore::Redis->new(%$args);
    is($redis2->get('26fe2bfb-73dd-4660-8946-bd14c899163b'), $some_value,
        'Redis->new correctly calls SELECT with the test database number');

    $redis->_connection->flushdb;
};

test 'Key setting/retrieving' => sub {
    is($redis->get('does-not-exist'), undef, 'Non-existent key returns undef');

    $redis->set('string', 'Esperándote');
    is($redis->get('string'), 'Esperándote', 'Retrieved expected string');

    $redis->set('ref', {
        artist => 'J Alvarez feat. Arcángel',
        title => 'Esperándote',
        duration => 215000
    });

    is_deeply($redis->get('ref'), {
        artist => 'J Alvarez feat. Arcángel',
        title => 'Esperándote',
        duration => 215000
    }, 'Retrieved expected data');

    ok(!$redis->exists('does-not-exist'), 'exists returns false for non-existent key');
    ok($redis->exists('string'), 'exists returns true for existing key');

    $redis->delete('string');
    ok(!$redis->exists('string'), 'exists returns false for deleted key');

    $redis->_connection->flushdb;
};

test 'Setting key expiration' => sub {
    $redis->set('int', 23);
    is($redis->get('int'), 23, 'Retrieved expected integer');

    $redis->expire_at('int', time() + 2);
    ok($redis->exists('int'), 'int still exists');
    sleep(2);
    ok(!$redis->exists('int'), 'int no longer exists');

    $redis->_connection->flushdb;
};

1;
