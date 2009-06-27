use strict;
use warnings;
use Test::More tests => 5;
use MusicBrainz::Server::CacheManager;
use Storable;
use_ok 'MusicBrainz::Server::Context';

{
    package TestCache1;
    use Moose;
    sub get { Storable::freeze(\'1') }
    sub set {}
    1;
    package TestCache2;
    use Moose;
    sub get { Storable::freeze(\'2') }
    sub set {}
    1;
}

my $cache_manager = MusicBrainz::Server::CacheManager->new(
    profiles => {
        test1 => {
            class => 'TestCache1',
            wrapped => 1,
            keys => ['foo'],
        },
        test2 => {
            class => 'TestCache2',
            wrapped => 1,
            keys => ['bar'],
        },
    },
    default_profile => 'test1',
);

my $c = MusicBrainz::Server::Context->new(cache_manager => $cache_manager);

is( $c->cache->get, '1' );
is( $c->cache('foo')->get, '1' );
is( $c->cache('baz')->get, '1' );
is( $c->cache('bar')->get, '2' );
