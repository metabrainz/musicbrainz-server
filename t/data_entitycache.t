use strict;
use warnings;
use Test::More tests => 14;

{
    package MyEntityData;
    use Moose;
    extends 'MusicBrainz::Server::Data::Entity';
    sub get_by_ids
    {
        my $self = shift;
        $self->get_called(1);
        return { 1 => 'data' };
    }

    package MyCachedEntityData;
    use Moose;
    extends 'MyEntityData';
    with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'prefix' };
    has 'get_called' => ( is => 'rw', isa => 'Bool', default => 0 );

    package MockCache;
    use Moose;
    has 'data' => ( is => 'rw', isa => 'HashRef', default => sub { +{} } );
    has 'get_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    has 'set_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    sub get
    {
        my ($self, $key) = @_;
        $self->get_called(1);
        return $self->data->{$key};
    }
    sub set
    {
        my ($self, $key, $data) = @_;
        $self->set_called(1);
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

my $entity = $entity_data->get_by_id(1);
is ( $entity, 'data' );
is ( $entity_data->get_called, 1 );
is ( $c->cache->_orig->get_called, 1 );
is ( $c->cache->_orig->set_called, 1 );
ok ( $c->cache->_orig->data->{'prefix:1'} =~ 'data' );

$entity_data->get_called(0);
$c->cache->_orig->get_called(0);
$c->cache->_orig->set_called(0);

$entity = $entity_data->get_by_id(1);
is ( $entity, 'data' );
is ( $entity_data->get_called, 0 );
is ( $c->cache->_orig->get_called, 1 );
is ( $c->cache->_orig->set_called, 0 );

delete $c->cache->_orig->data->{'prefix:1'};
$entity = $entity_data->get_by_id(1);
is ( $entity, 'data' );
is ( $entity_data->get_called, 1 );
is ( $c->cache->_orig->get_called, 1 );
is ( $c->cache->_orig->set_called, 1 );
ok ( $c->cache->_orig->data->{'prefix:1'} =~ 'data' );
