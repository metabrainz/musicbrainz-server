use strict;
use warnings;
use Test::More tests => 5;
use_ok 'MusicBrainz::Server::CacheManager';

{
    package TestCache1;
    use Moose;
    sub get { '1' }
    sub set {}
    1;
    package TestCache2;
    use Moose;
    has 'value' => ( is => 'ro' );
    sub get { shift->value }
    sub set {}
    1;
}

my $cache_manager = MusicBrainz::Server::CacheManager->new(
    profiles => {
        test1 => {
            class => 'TestCache1',
            keys => ['foo'],
        },
        test2 => {
            class => 'TestCache2',
            options => { value => '2' },
            keys => ['bar'],
        },
    },
    default_profile => 'test1',
);

is( $cache_manager->cache->get, '1' );
is( $cache_manager->cache('foo')->get, '1' );
is( $cache_manager->cache('baz')->get, '1' );
is( $cache_manager->cache('bar')->get, '2' );
