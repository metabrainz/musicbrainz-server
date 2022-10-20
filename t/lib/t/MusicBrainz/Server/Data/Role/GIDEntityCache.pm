package t::MusicBrainz::Server::Data::Role::GIDEntityCache;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::Context;

with 't::Context' => { -excludes => '_build_context' };

{
    package t::GIDEntityCache::MyEntity;
    use Moose;
    extends 'MusicBrainz::Server::Entity::CoreEntity';

    package t::GIDEntityCache::MyEntityData;
    use Moose;
    extends 'MusicBrainz::Server::Data::CoreEntity';
    has 'get_by_id_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    has 'get_by_gid_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    sub get_by_ids
    {
        my $self = shift;
        $self->get_by_id_called(1);
        return { 1 => t::GIDEntityCache::MyEntity->new(id => 1, gid => 'abc') };
    }
    sub get_by_gid
    {
        my $self = shift;
        $self->get_by_gid_called(1);
        return t::GIDEntityCache::MyEntity->new(id => 1, gid => 'abc');
    }

    package t::GIDEntityCache::MyCachedEntityData;
    use Moose;
    extends 't::GIDEntityCache::MyEntityData';
    with 'MusicBrainz::Server::Data::Role::GIDEntityCache';
    sub _type { 'my_cached_entity_data' }
    sub _cache_id { 1 }

    package t::GIDEntityCache::MockCache;
    use Moose;
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
my $entity_data = t::GIDEntityCache::MyCachedEntityData->new(c => $test->c);

my $entity = $entity_data->get_by_gid('abc');
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 1 );
is ( $entity_data->get_by_id_called, 0 );
is ( $test->c->cache->_orig->get_called, 1 );
is ( $test->c->cache->_orig->set_called, 2 );
ok ( $test->c->cache->_orig->data->{'my_cached_entity_data:1'} =~ '1' );
ok ( $test->c->cache->_orig->data->{'my_cached_entity_data:abc'} =~ '1' );


$entity_data->get_by_gid_called(0);
$entity_data->get_by_id_called(0);
$test->c->cache->_orig->get_called(0);
$test->c->cache->_orig->set_called(0);

$entity = $entity_data->get_by_gid('abc');
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

$entity = $entity_data->get_by_gid('abc');
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 0 );
is ( $entity_data->get_by_id_called, 1 );
is ( $test->c->cache->_orig->get_called, 2 );
is ( $test->c->cache->_orig->set_called, 2 );


};

test 'Cache is transactional (MBS-7241)' => sub {
    # This test is of limited usefulness, since it only tests a *single* point
    # in the transaction where an entity might be requested. But it at least
    # detects cases where there is *no* transactionality, i.e. the situation we
    # had before MBS-7241 was fixed.
    my $test = shift;

    use DBDefs;
    use MusicBrainz::Server::Data::Artist;
    use MusicBrainz::Server::Context;
    use Sql;

    no warnings 'redefine';

    # Important: each context needs a separate database connection (fresh_connector).
    my $c1 = MusicBrainz::Server::Context->create_script_context(database => 'TEST', fresh_connector => 1);
    my $c2 = MusicBrainz::Server::Context->create_script_context(database => 'TEST', fresh_connector => 1);
    my $_delete_from_cache = MusicBrainz::Server::Data::Artist->can('_delete_from_cache');

    $c1->sql->auto_commit(1);
    $c1->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (3, '31456bd3-0e1a-4c47-a5cc-e147a42965f2', 'Test', 'Test');
        SQL

    my $artist_gid = '31456bd3-0e1a-4c47-a5cc-e147a42965f2';

    *MusicBrainz::Server::Data::Artist::_delete_from_cache = sub {
        my $artist = $c2->model('Artist')->get_by_id(3);
        is($artist->id, 3,
            'concurrent get_by_id returns artist before ' .
            'database deletion commits, and before cache deletion');

        $artist = $c2->model('Artist')->get_by_gid($artist_gid);
        is($artist->id, 3,
            'concurrent get_by_gid returns artist before ' .
            'database deletion commits, and before cache deletion');

        ok($c2->cache->get('artist:3')->isa('MusicBrainz::Server::Entity::Artist'),
            'cache contains artist entity');

        $_delete_from_cache->(@_);

        $artist = $c2->model('Artist')->get_by_id(3);
        is($artist->id, 3,
            'concurrent get_by_id returns artist before ' .
            'database deletion commits, but after cache deletion');

        is($c2->cache->get('artist:3'), undef,
            'cache is not repopulated after concurrent get_by_id');

        $artist = $c2->model('Artist')->get_by_gid($artist_gid);
        is($artist->id, 3,
            'concurrent get_by_gid returns artist before ' .
            'database deletion commits, but after cache deletion');

        is($c2->cache->get('artist:3'), undef,
            'cache is not repopulated after concurrent get_by_gid');
    };

    Sql::run_in_transaction(sub {
        $c1->model('Artist')->delete(3);
    }, $c1->sql);

    my $artist = $c1->model('Artist')->get_by_id(3);
    ok(!defined $artist,
        'get_by_id returns undef after ' .
        'database deletion commits, and after cache deletion');

    $c1->sql->auto_commit(1);
    $c1->sql->do(<<~'SQL');
        DELETE FROM artist WHERE id = 3;
        DELETE FROM deleted_entity WHERE gid = '31456bd3-0e1a-4c47-a5cc-e147a42965f2';
        SQL

    *MusicBrainz::Server::Data::Artist::_delete_from_cache = $_delete_from_cache;
    $c1->connector->disconnect;
    $c2->connector->disconnect;
};

1;
