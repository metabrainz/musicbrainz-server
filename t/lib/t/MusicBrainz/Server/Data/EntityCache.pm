package t::MusicBrainz::Server::Data::EntityCache;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

{
    package MyEntityData;
    use Moose;
    extends 'MusicBrainz::Server::Data::Entity';
    sub _type { 'my_entity_data' }
    sub get_by_ids
    {
        my $self = shift;
        $self->get_called(1);
        return { 1 => 'data' };
    }

    package MyCachedEntityData;
    use Moose;
    extends 'MyEntityData';
    with 'MusicBrainz::Server::Data::Role::EntityCache';
    has 'get_called' => ( is => 'rw', isa => 'Bool', default => 0 );
    sub _cache_id { 1 }

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

with 't::Context' => { -excludes => '_build_context' };

sub _build_context {
    my $cache_manager = MusicBrainz::Server::CacheManager->new(
        profiles => {
            test => {
                class => 'MockCache',
                wrapped => 1,
                keys => ['my_entity_data'],
            },
        },
        default_profile => 'test',
    );

    return MusicBrainz::Server::Context->new(cache_manager => $cache_manager);
}

test all => sub {

my $test = shift;

my $entity_data = MyCachedEntityData->new(c => $test->c);

my $entity = $entity_data->get_by_id(1);
is ( $entity, 'data' );
is ( $entity_data->get_called, 1 );
is ( $test->c->cache->_orig->get_called, 1 );
is ( $test->c->cache->_orig->set_called, 1 );
ok ( $test->c->cache->_orig->data->{'my_entity_data:1'} =~ 'data' );


$entity_data->get_called(0);
$test->c->cache->_orig->get_called(0);
$test->c->cache->_orig->set_called(0);

$entity = $entity_data->get_by_id(1);
is ( $entity, 'data' );
is ( $entity_data->get_called, 0 );
is ( $test->c->cache->_orig->get_called, 1 );
is ( $test->c->cache->_orig->set_called, 0 );


delete $test->c->cache->_orig->data->{'my_entity_data:1'};
$entity = $entity_data->get_by_id(1);
is ( $entity, 'data' );
is ( $entity_data->get_called, 1 );
is ( $test->c->cache->_orig->get_called, 1 );
is ( $test->c->cache->_orig->set_called, 1 );
ok ( $test->c->cache->_orig->data->{'my_entity_data:1'} =~ 'data' );

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
