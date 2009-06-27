use strict;
use warnings;
use Test::More tests => 17;

{
    package MyEntity;
    use Moose;
    extends 'MusicBrainz::Server::Entity::CoreEntity';

    package MyEntityData;
    use Moose;
    extends 'MusicBrainz::Server::Data::CoreEntity';
    has 'get_by_id_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    has 'get_by_gid_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    sub get_by_ids
    {
        my $self = shift;
        $self->get_by_id_called(1);
        return { 1 => MyEntity->new(id => 1, gid => 'abc') };
    }
    sub get_by_gid
    {
        my $self = shift;
        $self->get_by_gid_called(1);
        return MyEntity->new(id => 1, gid => 'abc');
    }

    package MyCachedEntityData;
    use Moose;
    extends 'MyEntityData';
    with 'MusicBrainz::Server::Data::CoreEntityCache' => { prefix => 'prefix' };

    package MockCache;
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

use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::Context;

my $cache_manager = MusicBrainz::Server::CacheManager->new(
    profiles => {
        test => {
            class => 'MockCache',
            wrapped => 1,
            keys => ['prefix'],
        },
    },
    default_profile => 'test',
);


my $c = MusicBrainz::Server::Context->new(cache_manager => $cache_manager);

my $entity_data = MyCachedEntityData->new(c => $c);

my $entity = $entity_data->get_by_gid('abc');
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 1 );
is ( $entity_data->get_by_id_called, 0 );
is ( $c->cache->_orig->get_called, 1 );
is ( $c->cache->_orig->set_called, 2 );
ok ( $c->cache->_orig->data->{'prefix:1'} =~ '1' );
ok ( $c->cache->_orig->data->{'prefix:abc'} =~ '1' );

$entity_data->get_by_gid_called(0);
$entity_data->get_by_id_called(0);
$c->cache->_orig->get_called(0);
$c->cache->_orig->set_called(0);

$entity = $entity_data->get_by_gid('abc');
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 0 );
is ( $entity_data->get_by_id_called, 0 );
is ( $c->cache->_orig->get_called, 2 );
is ( $c->cache->_orig->set_called, 0 );

$entity_data->get_by_gid_called(0);
$entity_data->get_by_id_called(0);
$c->cache->_orig->get_called(0);
$c->cache->_orig->set_called(0);

delete $c->cache->_orig->data->{'prefix:1'};

$entity = $entity_data->get_by_gid('abc');
is ( $entity->id, 1 );
is ( $entity_data->get_by_gid_called, 0 );
is ( $entity_data->get_by_id_called, 1 );
is ( $c->cache->_orig->get_called, 2 );
is ( $c->cache->_orig->set_called, 2 );
