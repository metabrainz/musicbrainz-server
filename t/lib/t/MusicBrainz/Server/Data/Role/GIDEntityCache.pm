package t::MusicBrainz::Server::Data::Role::GIDEntityCache;

use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Try::Tiny;

use DBDefs;
use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::CacheWrapper::Redis;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Artist;
use Sql;

with 't::Context' => { -excludes => '_build_context' };

our $gid1 = '3f8c4788-d193-4931-b6b7-3aa7bf64ac33';

{
    package t::GIDEntityCache::MyEntity;
    use Moose;
    use namespace::autoclean;
    extends 'MusicBrainz::Server::Entity';
    with 'MusicBrainz::Server::Entity::Role::Relatable';

    package t::GIDEntityCache::MyEntityData;
    use Moose;
    use namespace::autoclean;
    extends 'MusicBrainz::Server::Data::Entity';
    with 'MusicBrainz::Server::Data::Role::GetByGID';
    has 'get_by_id_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    has 'get_by_gid_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    sub get_by_ids
    {
        my $self = shift;
        $self->get_by_id_called(1);
        return { 1 => t::GIDEntityCache::MyEntity->new(id => 1, gid => $gid1) };
    }
    sub get_by_gid
    {
        my $self = shift;
        $self->get_by_gid_called(1);
        return t::GIDEntityCache::MyEntity->new(id => 1, gid => $gid1);
    }

    package t::GIDEntityCache::MyCachedEntityData;
    use Moose;
    use namespace::autoclean;
    extends 't::GIDEntityCache::MyEntityData';
    with 'MusicBrainz::Server::Data::Role::GIDEntityCache';
    sub _type { 'my_cached_entity_data' }

    package t::GIDEntityCache::MockCache;
    use Moose;
    use namespace::autoclean;
    has 'data' => ( is => 'rw', isa => 'HashRef', default => sub { +{} } );
    has 'get_called' => ( is => 'rw', isa => 'Int', default => 0 );
    has 'set_called' => ( is => 'rw', isa => 'Int', default => 0 );
    sub get
    {
        my ($self, $key) = @_;
        $self->get_called($self->get_called + 1);
        return $self->data->{$key};
    }
    sub set
    {
        my ($self, $key, $data) = @_;
        $self->set_called($self->set_called + 1);
        $self->data->{$key} = $data;
    }
}

sub _build_context {
    my $cache_manager = MusicBrainz::Server::CacheManager->new(
        profiles => {
            test => {
                class => 't::GIDEntityCache::MockCache',
                wrapped => 1,
                keys => ['my_cached_entity_data'],
            },
        },
        default_profile => 'test',
    );

    return MusicBrainz::Server::Context->new(cache_manager => $cache_manager);
}

test all => sub {

my $test = shift;
my $c = $test->c;
my $sql = $c->sql;
my $entity_data = t::GIDEntityCache::MyCachedEntityData->new(c => $c);

$sql->begin;
my $entity = $entity_data->get_by_gid($gid1);
$sql->commit;
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 1 );
is ( $entity_data->get_by_id_called, 0 );
is ( $test->c->cache->_orig->get_called, 1 );
is ( $test->c->cache->_orig->set_called, 4 );
ok ( $test->c->cache->_orig->data->{'my_cached_entity_data:1'} =~ '1' );
ok ( $test->c->cache->_orig->data->{"my_cached_entity_data:$gid1"} =~ '1' );


$entity_data->get_by_gid_called(0);
$entity_data->get_by_id_called(0);
$test->c->cache->_orig->get_called(0);
$test->c->cache->_orig->set_called(0);

$sql->begin;
$entity = $entity_data->get_by_gid($gid1);
$sql->commit;
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 0 );
is ( $entity_data->get_by_id_called, 0 );
is ( $test->c->cache->_orig->get_called, 2 );
is ( $test->c->cache->_orig->set_called, 0 );


$entity_data->get_by_gid_called(0);
$entity_data->get_by_id_called(0);
$test->c->cache->_orig->get_called(0);
$test->c->cache->_orig->set_called(0);

delete $test->c->cache->_orig->data->{'my_cached_entity_data:1'};

$sql->begin;
$entity = $entity_data->get_by_gid($gid1);
$sql->commit;
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 0 );
is ( $entity_data->get_by_id_called, 1 );
is ( $test->c->cache->_orig->get_called, 2 );
is ( $test->c->cache->_orig->set_called, 2 );


};

test 'Cache is transactional (MBS-7241)' => sub {
    my $test = shift;

    no warnings 'redefine';

    # Important: each context needs a separate database connection (fresh_connector).
    my $c1 = $test->_build_cache_aware_context;
    my $c2 = $test->_build_cache_aware_context;

    $c1->connector->disconnect;
    $c1->clear_connector;

    $c2->connector->disconnect;
    $c2->clear_connector;

    my $_delete_from_cache = MusicBrainz::Server::Data::Artist->can('_delete_from_cache');

    $c1->sql->auto_commit(1);
    $c1->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (3, '31456bd3-0e1a-4c47-a5cc-e147a42965f2', 'Test', 'Test');
        SQL

    my $cleanup = sub {
        $c1->sql->auto_commit(1);
        $c1->sql->do(<<~'SQL');
            DELETE FROM artist WHERE id = 3;
            DELETE FROM deleted_entity WHERE gid = '31456bd3-0e1a-4c47-a5cc-e147a42965f2';
            SQL
        $c1->store->delete('artist:recently_invalidated:3');
    };

    my $artist_gid = '31456bd3-0e1a-4c47-a5cc-e147a42965f2';
    my $do_update = 1;
    my $error;

    # Test 1:
    #  1. Process A fetches artist 3 (not in the cache).
    #  2. Process B updates artist 3 and commits (deleting it from the
    #     cache).
    #  3. Process A finally adds artist 3 to the cache.
    # Expectation: artist 3 should not exist in the cache.

    my $set_multi = MusicBrainz::Server::CacheWrapper::Redis->can('set_multi');
    *MusicBrainz::Server::CacheWrapper::Redis::set_multi = sub {
        if ($do_update) {
            $do_update = 0;
            $c2->sql->begin;
            $c2->model('Artist')->update(3, {name => 'COOL'});
            $c2->sql->commit;
        }
        $set_multi->(@_);
    };

    try {
        $c1->sql->begin;
        # Attempt to cache this artist. A concurrent process will update the
        # same artist before this process adds it to the cache (see the
        # `set_multi` redefinition above), which should prevent our stale
        # cache addition.
        $c1->model('Artist')->get_by_gid($artist_gid);
        $c1->sql->commit;

        ok(!$c1->cache->exists('artist:3'),
           'artist is not cached after a concurrent update');

        $c1->sql->begin;
        my $artist = $c1->model('Artist')->get_by_gid($artist_gid);
        is($artist->name, 'COOL', 'get_by_gid returns the latest changes');
        $c1->sql->commit;
    } catch {
        $error = $_;
    } finally {
        *MusicBrainz::Server::CacheWrapper::Redis::set_multi = $set_multi; ## no critic (ProtectPrivateVars)
    };

    if ($error) {
        $cleanup->();
        die $error;
    }

    $c1->store->delete('artist:recently_invalidated:3');

    # Test 2:
    #  1. Process A deletes artist 3 (but doesn't commit yet).
    #  2. Process B fetches artist 3:
    #     a. before the cache deletion,
    #     b. after the cache deletion but before process A commits,
    #     c. and finally after process A commits.
    # We test `get_by_gid` and the presence of artist 3 in the cache at each
    # interval in the points above.

    $c1->sql->begin;
    $c1->model('Artist')->get_by_gid($artist_gid);
    $c1->sql->commit;

    *MusicBrainz::Server::Data::Artist::_delete_from_cache = sub { ## no critic (ProtectPrivateVars)
        my $artist = $c2->model('Artist')->get_by_id(3);

        my $status = 'before database deletion commits, ' .
            'and before cache deletion';

        is($artist->id, 3,
            '(a.) concurrent get_by_id returns artist ' . $status);

        $artist = $c2->model('Artist')->get_by_gid($artist_gid);
        is($artist->id, 3,
            '(a.) concurrent get_by_gid returns artist ' . $status);

        ok($c2->cache->get('artist:3')->isa('MusicBrainz::Server::Entity::Artist'),
            '(a.) cache contains artist entity ' . $status);

        $_delete_from_cache->(@_);

        $status = 'before database deletion commits, ' .
            'but after cache deletion';

        $artist = $c2->model('Artist')->get_by_id(3);
        is($artist->id, 3,
            '(b.) concurrent get_by_id returns artist ' . $status);

        is($c2->cache->get('artist:3'), undef,
            '(b.) cache is not repopulated after concurrent get_by_id ' .
            $status);

        $artist = $c2->model('Artist')->get_by_gid($artist_gid);
        is($artist->id, 3,
            '(b.) concurrent get_by_gid returns artist ' . $status);

        is($c2->cache->get('artist:3'), undef,
            '(b.) cache is not repopulated after concurrent get_by_gid' .
            $status);
    };

    try {
        Sql::run_in_transaction(sub {
            $c1->model('Artist')->delete(3);
        }, $c1->sql);

        my $artist = $c1->model('Artist')->get_by_id(3);
        ok(!defined $artist,
            '(c.) get_by_id returns undef after ' .
            'database deletion commits, and after cache deletion');
    } catch {
        $error = $_;
    } finally {
        *MusicBrainz::Server::Data::Artist::_delete_from_cache = $_delete_from_cache; ## no critic (ProtectPrivateVars)
        $cleanup->();
        $c1->connector->disconnect;
        $c2->connector->disconnect;
    };

    die $error if $error;
};

test 'Redirected gids are cached' => sub {
    my $test = shift;
    my $c = $test->cache_aware_c;

    $c->sql->begin;
    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
             VALUES (3, '5809b63b-73d9-406c-b67d-f145a5a9b696', 'A', 'A');
        INSERT INTO artist_gid_redirect
             VALUES ('6322dacd-64c9-4ae8-a7ca-eada3f8abf2e', 3);
        SQL
    $c->model('Artist')->get_by_gid('6322dacd-64c9-4ae8-a7ca-eada3f8abf2e');
    $c->sql->commit;

    ok($c->cache->get('artist:3')->isa('MusicBrainz::Server::Entity::Artist'),
       'id is cached');

    is($c->cache->get('artist:5809b63b-73d9-406c-b67d-f145a5a9b696'),
       3,
       'gid is cached');

    is($c->cache->get('artist:6322dacd-64c9-4ae8-a7ca-eada3f8abf2e'),
       3,
       'redirected gid is cached');

    $c->sql->auto_commit(1);
    $c->sql->do(<<~'SQL');
        DELETE FROM artist_gid_redirect WHERE new_id = 3;
        DELETE FROM artist WHERE id = 3;
        SQL
};

1;
