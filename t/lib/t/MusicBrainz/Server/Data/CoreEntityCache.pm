package t::MusicBrainz::Server::Data::CoreEntityCache;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::Context;

with 't::Context' => { -excludes => '_build_context' };

{
    package t::CoreEntityCache::MyEntity;
    use Moose;
    extends 'MusicBrainz::Server::Entity::CoreEntity';

    package t::CoreEntityCache::MyEntityData;
    use Moose;
    extends 'MusicBrainz::Server::Data::CoreEntity';
    has 'get_by_id_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    has 'get_by_gid_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    sub get_by_ids
    {
        my $self = shift;
        $self->get_by_id_called(1);
        return { 1 => t::CoreEntityCache::MyEntity->new(id => 1, gid => 'abc') };
    }
    sub get_by_gid
    {
        my $self = shift;
        $self->get_by_gid_called(1);
        return t::CoreEntityCache::MyEntity->new(id => 1, gid => 'abc');
    }

    package t::CoreEntityCache::MyCachedEntityData;
    use Moose;
    extends 't::CoreEntityCache::MyEntityData';
    with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'prefix' };

    package t::CoreEntityCache::MockCache;
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
                class => 't::CoreEntityCache::MockCache',
                wrapped => 1,
                keys => ['prefix'],
            },
        },
        default_profile => 'test',
    );

    return MusicBrainz::Server::Context->new(cache_manager => $cache_manager);
}

test all => sub {

my $test = shift;
my $entity_data = t::CoreEntityCache::MyCachedEntityData->new(c => $test->c);

my $entity = $entity_data->get_by_gid('abc');
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 1 );
is ( $entity_data->get_by_id_called, 0 );
is ( $test->c->cache->_orig->get_called, 1 );
is ( $test->c->cache->_orig->set_called, 2 );
ok ( $test->c->cache->_orig->data->{'prefix:1'} =~ '1' );
ok ( $test->c->cache->_orig->data->{'prefix:abc'} =~ '1' );


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

delete $test->c->cache->_orig->data->{'prefix:1'};

$entity = $entity_data->get_by_gid('abc');
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 0 );
is ( $entity_data->get_by_id_called, 1 );
is ( $test->c->cache->_orig->get_called, 2 );
is ( $test->c->cache->_orig->set_called, 2 );


};

1;
