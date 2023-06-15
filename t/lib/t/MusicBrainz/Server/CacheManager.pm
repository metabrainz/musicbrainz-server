package t::MusicBrainz::Server::CacheManager;
use strict;
use warnings;

use Test::Routine;
use Test::More;

{
    package t::MusicBrainz::Server::CacheManager::TestCache1;
    use Moose;
    use namespace::autoclean;
    sub get { '1' }
    sub set {}
    1;
    package t::MusicBrainz::Server::CacheManager::TestCache2;
    use Moose;
    use namespace::autoclean;
    has 'value' => ( is => 'ro' );
    sub get { shift->value }
    sub set {}
    1;
}


test 'Check CacheManager routing' => sub {
    my $test = shift;

    my $cache_manager = MusicBrainz::Server::CacheManager->new(
        profiles => {
            test1 => {
                class => 't::MusicBrainz::Server::CacheManager::TestCache1',
                keys => ['foo'],
            },
            test2 => {
                class => 't::MusicBrainz::Server::CacheManager::TestCache2',
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
};

1;
