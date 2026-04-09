package t::MusicBrainz::DataStore::Valkey;

use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::DataStore::Valkey;
use DBDefs;

with 't::Context';

=head1 DESCRIPTION

This test checks basic tasks for the Valkey store, including adding, deleting
and expiring keys.

=cut

# Initialize tests
my $args = DBDefs->DATASTORE_REDIS_ARGS;
$args->{database} = DBDefs->REDIS_TEST_DATABASE;
my $valkey = MusicBrainz::DataStore::Valkey->new(%$args);

test 'Database is still selected in new Valkey copy' => sub {
    my $some_value = rand();
    $valkey->set('26fe2bfb-73dd-4660-8946-bd14c899163b', $some_value);

    # The above commands have set a known value in the test database.
    # Now initialize another copy of Valkey->new and have it call
    # select(), and verify that our value is still there.
    my $valkey2 = MusicBrainz::DataStore::Valkey->new(%$args);
    is($valkey2->get('26fe2bfb-73dd-4660-8946-bd14c899163b'), $some_value,
        'Valkey->new correctly calls SELECT with the test database number');

    $valkey->_connection->flushdb;
};

test 'Key setting/retrieving' => sub {
    is($valkey->get('does-not-exist'), undef, 'Non-existent key returns undef');

    $valkey->set('string', 'Esperándote');
    is($valkey->get('string'), 'Esperándote', 'Retrieved expected string');

    $valkey->set('ref', {
        artist => 'J Alvarez feat. Arcángel',
        title => 'Esperándote',
        duration => 215000,
    });

    is_deeply($valkey->get('ref'), {
        artist => 'J Alvarez feat. Arcángel',
        title => 'Esperándote',
        duration => 215000,
    }, 'Retrieved expected data');

    ok(!$valkey->exists('does-not-exist'), 'exists returns false for non-existent key');
    ok($valkey->exists('string'), 'exists returns true for existing key');

    $valkey->delete('string');
    ok(!$valkey->exists('string'), 'exists returns false for deleted key');

    $valkey->_connection->flushdb;
};

test 'Setting key expiration' => sub {
    $valkey->set('int', 23);
    is($valkey->get('int'), 23, 'Retrieved expected integer');

    $valkey->expire_at('int', time() + 2);
    ok($valkey->exists('int'), 'int still exists');
    sleep(2);
    ok(!$valkey->exists('int'), 'int no longer exists');

    $valkey->_connection->flushdb;
};

1;
