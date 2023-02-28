package t::MusicBrainz::DataStore::RedisMulti;

use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );
use MusicBrainz::Server::Test;
use MusicBrainz::DataStore::Redis;
use MusicBrainz::DataStore::RedisMulti;
use DBDefs;

=head2 Test description

This test checks basic tasks for the RedisMulti store (including adding,
deleting and expiring keys), which distributes queries to multiple underlying
stores. Consistency among all the stores is checked after each operation.

=cut

# Initialize tests
my $args1 = DBDefs->DATASTORE_REDIS_ARGS;
$args1->{database} = $args1->{test_database};

my $args2 = DBDefs->DATASTORE_REDIS_ARGS;
$args2->{database} = $args2->{test_database} + 1;

my $redis1 = MusicBrainz::DataStore::Redis->new($args1);
my $redis2 = MusicBrainz::DataStore::Redis->new($args2);

my $redis_multi = MusicBrainz::DataStore::RedisMulti->new(
    _redis_instances => [$redis1, $redis2],
);

# This doesn't test RedisMulti behavior specifically, but is a prerequisite
# for the rest of these tests to make sense.
test 'Databases are separate' => sub {
    $redis1->set('kx1', 'vx1');
    $redis2->set('kx2', 'vx2');

    is($redis1->get('kx1'), 'vx1', 'Expected string is in database 1');
    is($redis2->exists('kx1'), 0, 'String from database 1 is not in database 2');

    is($redis2->get('kx2'), 'vx2', 'Expected string is in database 2');
    is($redis1->exists('kx2'), 0, 'String from database 2 is not in database 1');

    $redis1->clear;
    $redis2->clear;
};

test 'Key setting/retrieving' => sub {
    is($redis_multi->get('does-not-exist'), undef, 'Non-existent key returns undef');

    $redis_multi->set('string', 'Esperándote');
    is($redis_multi->get('string'), 'Esperándote', 'Retrieved expected string');
    is($redis1->get('string'), 'Esperándote', 'Expected string is in database 1');
    is($redis2->get('string'), 'Esperándote', 'Expected string is in database 2');

    $redis1->set('string-1-only', '1-only');
    $redis2->set('string-2-only', '2-only');
    is($redis_multi->get('string-1-only'), '1-only', 'Retrieved string that was only set in database 1');
    is($redis_multi->get('string-2-only'), '2-only', 'Retrieved string that was only set in database 2');

    is($redis_multi->exists('does-not-exist'), 0, 'exists returns 0 for non-existent key');
    is($redis1->exists('does-not-exist'), 0, 'exists returns 0 for non-existent key in database 1');
    is($redis2->exists('does-not-exist'), 0, 'exists returns 0 for non-existent key in database 2');

    is($redis_multi->exists('string'), 1, 'exists returns 1 for existing key');
    is($redis1->exists('string'), 1, 'exists returns 1 for existing key in database 1');
    is($redis2->exists('string'), 1, 'exists returns 1 for existing key in database 2');

    $redis_multi->delete('string');
    is($redis_multi->exists('string'), 0, 'exists returns 0 for deleted key');
    is($redis1->exists('string'), 0, 'exists returns 0 for deleted key in database 1');
    is($redis2->exists('string'), 0, 'exists returns 0 for deleted key in database 2');

    $redis_multi->set_multi(['k1', 'v1'], ['k2', 'v2']);
    is_deeply(
        $redis_multi->get_multi('k1', 'k2'),
        { k1 => 'v1', k2 => 'v2' },
        'Retrieved expected multiple values',
    );
    is_deeply(
        $redis1->get_multi('k1', 'k2'),
        { k1 => 'v1', k2 => 'v2' },
        'Retrieved expected multiple values from database 1',
    );
    is_deeply(
        $redis2->get_multi('k1', 'k2'),
        { k1 => 'v1', k2 => 'v2' },
        'Retrieved expected multiple values from database 2',
    );

    $redis_multi->delete_multi('k1', 'k2');
    is($redis_multi->exists('k1'), 0, 'exists returns 0 for first deleted key');
    is($redis_multi->exists('k2'), 0, 'exists returns 0 for second deleted key');
    is($redis1->exists('k1'), 0, 'exists returns 0 for first deleted key in database 1');
    is($redis1->exists('k2'), 0, 'exists returns 0 for second deleted key in database 1');
    is($redis2->exists('k1'), 0, 'exists returns 0 for first deleted key in database 2');
    is($redis2->exists('k2'), 0, 'exists returns 0 for second deleted key in database 2');

    $redis_multi->set_add('setk', qw( v1 v2 v3 ));
    my @set_values = $redis_multi->set_members('setk');
    cmp_bag(\@set_values, [qw( v1 v2 v3 )], 'Retrieved expected set members');
    @set_values = $redis1->set_members('setk');
    cmp_bag(\@set_values, [qw( v1 v2 v3 )], 'Retrieved expected set members from database 1');
    @set_values = $redis2->set_members('setk');
    cmp_bag(\@set_values, [qw( v1 v2 v3 )], 'Retrieved expected set members from database 2');

    $redis_multi->clear;
};

test 'Setting key expiration' => sub {
    $redis_multi->set('int', 23);
    $redis_multi->expire_at('int', time() + 2);
    ok($redis_multi->exists('int'), 'int still exists');
    ok($redis1->exists('int'), 'int still exists in database 1');
    ok($redis2->exists('int'), 'int still exists in database 2');
    sleep(2);
    ok(!$redis_multi->exists('int'), 'int no longer exists');
    ok(!$redis1->exists('int'), 'int no longer exists in database 1');
    ok(!$redis2->exists('int'), 'int no longer exists in database 2');
    $redis_multi->clear;
};

1;
