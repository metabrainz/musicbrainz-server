package t::MusicBrainz::DataStore::Redis;
use Test::Routine;
use Test::Moose;
use Test::More;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::DataStore::Redis;
use DBDefs;

with 't::Context';

test "test database selected" => sub {
    my $test = shift;

    my $args = DBDefs->DATASTORE_REDIS_ARGS;
    $args->{database} = $args->{test_database};

    # Redis doesn't seem to have a way to query which database is
    # selected.  The following code works around that to verify
    # that Redis->new() correctly selects the requested database.

    my $redis = MusicBrainz::DataStore::Redis->new (%$args);
    $redis->_connection->select ($args->{test_database});

    my $some_value = rand ();
    $redis->set ("MB:26fe2bfb-73dd-4660-8946-bd14c899163b", $some_value);

    # The above commands have set a known value in the test database.
    # Now initialize another copy of Redis->new and have it call
    # select(), and verify that our value is still there.
    my $redis2 = MusicBrainz::DataStore::Redis->new (%$args);
    is ($redis2->get ("MB:26fe2bfb-73dd-4660-8946-bd14c899163b"), $some_value,
        "Redis->new correctly calls SELECT with the test database number");
};

test all => sub {
    my $test = shift;

    my $args = DBDefs->DATASTORE_REDIS_ARGS;

    $args->{database} = $args->{test_database};

    my $redis = MusicBrainz::DataStore::Redis->new (%$args);

    $redis->_flushdb ();

    is ($redis->get ("does-not-exist"), undef, "non-existent key returns undef");

    ok ($redis->set ("string", "Esperándote"), "set string");
    is ($redis->get ("string"), "Esperándote", "retrieved expected string");

    ok ($redis->set ("ref", {
        artist => "J Alvarez feat. Arcángel",
        title => "Esperándote",
        duration => 215000
    }), "set data");

    is_deeply ($redis->get ("ref"), {
        artist => "J Alvarez feat. Arcángel",
        title => "Esperándote",
        duration => 215000
    }, "retrieved expected data");


    ok (! $redis->exists ("does-not-exist"), "exists returns false for non-existent key");
    ok ($redis->exists ("string"), "exists returns true for existing key");

    ok (! $redis->add ("string", "Murió"), "add returns false when not adding a key");
    is ($redis->get ("string"), "Esperándote", "string is unchanged");

    ok ($redis->del ("string"), "delete string");
    ok (! $redis->exists ("strings"), "exists returns false for deleted key");

    ok ($redis->add ("string", "Murió"), "add returns true when adding a key");
    is ($redis->get ("string"), "Murió", "string is now changed");

    $redis->set ("int", 23);
    is ($redis->get ("int"), 23, "retrieved expected integer");

    $redis->incr ("int", 2);
    is ($redis->get ("int"), 25, "retrieved incremented integer");

    ok ($redis->expireat ("int", time () + 1), "expire int in one second");
    ok ($redis->exists ("int"), "int still exists");
    sleep (2);
    ok (! $redis->exists ("int"), "int no longer exists");
};

1;

