package t::MusicBrainz::DataStore::ValkeyMulti;

use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );
use MusicBrainz::Server::Test;
use MusicBrainz::DataStore::Valkey;
use MusicBrainz::DataStore::ValkeyMulti;
use DBDefs;

=head1 DESCRIPTION

This test checks basic tasks for the ValkeyMulti store (including adding,
deleting and expiring keys), which distributes queries to multiple underlying
stores. Consistency among all the stores is checked after each operation.

=cut

# Initialize tests
my $args1 = DBDefs->DATASTORE_VALKEY_ARGS;
$args1->{database} = DBDefs->VALKEY_TEST_DATABASE;

my $args2 = DBDefs->DATASTORE_VALKEY_ARGS;
$args2->{database} = DBDefs->VALKEY_TEST_DATABASE + 1;

my $valkey1 = MusicBrainz::DataStore::Valkey->new($args1);
my $valkey2 = MusicBrainz::DataStore::Valkey->new($args2);

my $valkey_multi = MusicBrainz::DataStore::ValkeyMulti->new(
    _redis_instances => [$valkey1, $valkey2],
);

# This doesn't test ValkeyMulti behavior specifically, but is a prerequisite
# for the rest of these tests to make sense.
test 'Databases are separate' => sub {
    $valkey1->set('kx1', 'vx1');
    $valkey2->set('kx2', 'vx2');

    is($valkey1->get('kx1'), 'vx1', 'Expected string is in database 1');
    is($valkey2->exists('kx1'), 0, 'String from database 1 is not in database 2');

    is($valkey2->get('kx2'), 'vx2', 'Expected string is in database 2');
    is($valkey1->exists('kx2'), 0, 'String from database 2 is not in database 1');

    $valkey1->clear;
    $valkey2->clear;
};

test 'Key setting/retrieving' => sub {
    is($valkey_multi->get('does-not-exist'), undef, 'Non-existent key returns undef');

    $valkey_multi->set('string', 'Esperándote');
    is($valkey_multi->get('string'), 'Esperándote', 'Retrieved expected string');
    is($valkey1->get('string'), 'Esperándote', 'Expected string is in database 1');
    is($valkey2->get('string'), 'Esperándote', 'Expected string is in database 2');

    $valkey1->set('string-1-only', '1-only');
    $valkey2->set('string-2-only', '2-only');
    is($valkey_multi->get('string-1-only'), '1-only', 'Retrieved string that was only set in database 1');
    is($valkey_multi->get('string-2-only'), '2-only', 'Retrieved string that was only set in database 2');

    is($valkey_multi->exists('does-not-exist'), 0, 'exists returns 0 for non-existent key');
    is($valkey1->exists('does-not-exist'), 0, 'exists returns 0 for non-existent key in database 1');
    is($valkey2->exists('does-not-exist'), 0, 'exists returns 0 for non-existent key in database 2');

    is($valkey_multi->exists('string'), 1, 'exists returns 1 for existing key');
    is($valkey1->exists('string'), 1, 'exists returns 1 for existing key in database 1');
    is($valkey2->exists('string'), 1, 'exists returns 1 for existing key in database 2');

    $valkey_multi->delete('string');
    is($valkey_multi->exists('string'), 0, 'exists returns 0 for deleted key');
    is($valkey1->exists('string'), 0, 'exists returns 0 for deleted key in database 1');
    is($valkey2->exists('string'), 0, 'exists returns 0 for deleted key in database 2');

    $valkey_multi->set_multi(['k1', 'v1'], ['k2', 'v2']);
    is_deeply(
        $valkey_multi->get_multi('k1', 'k2'),
        { k1 => 'v1', k2 => 'v2' },
        'Retrieved expected multiple values',
    );
    is_deeply(
        $valkey1->get_multi('k1', 'k2'),
        { k1 => 'v1', k2 => 'v2' },
        'Retrieved expected multiple values from database 1',
    );
    is_deeply(
        $valkey2->get_multi('k1', 'k2'),
        { k1 => 'v1', k2 => 'v2' },
        'Retrieved expected multiple values from database 2',
    );

    $valkey_multi->delete_multi('k1', 'k2');
    is($valkey_multi->exists('k1'), 0, 'exists returns 0 for first deleted key');
    is($valkey_multi->exists('k2'), 0, 'exists returns 0 for second deleted key');
    is($valkey1->exists('k1'), 0, 'exists returns 0 for first deleted key in database 1');
    is($valkey1->exists('k2'), 0, 'exists returns 0 for second deleted key in database 1');
    is($valkey2->exists('k1'), 0, 'exists returns 0 for first deleted key in database 2');
    is($valkey2->exists('k2'), 0, 'exists returns 0 for second deleted key in database 2');

    $valkey_multi->set_add('setk', qw( v1 v2 v3 ));
    my @set_values = $valkey_multi->set_members('setk');
    cmp_bag(\@set_values, [qw( v1 v2 v3 )], 'Retrieved expected set members');
    @set_values = $valkey1->set_members('setk');
    cmp_bag(\@set_values, [qw( v1 v2 v3 )], 'Retrieved expected set members from database 1');
    @set_values = $valkey2->set_members('setk');
    cmp_bag(\@set_values, [qw( v1 v2 v3 )], 'Retrieved expected set members from database 2');

    $valkey_multi->clear;
};

test 'Setting key expiration' => sub {
    $valkey_multi->set('int', 23);
    $valkey_multi->expire_at('int', time() + 2);
    ok($valkey_multi->exists('int'), 'int still exists');
    ok($valkey1->exists('int'), 'int still exists in database 1');
    ok($valkey2->exists('int'), 'int still exists in database 2');
    sleep(2);
    ok(!$valkey_multi->exists('int'), 'int no longer exists');
    ok(!$valkey1->exists('int'), 'int no longer exists in database 1');
    ok(!$valkey2->exists('int'), 'int no longer exists in database 2');
    $valkey_multi->clear;
};

1;
