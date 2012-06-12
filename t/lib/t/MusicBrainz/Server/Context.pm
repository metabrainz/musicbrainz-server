package t::MusicBrainz::Server::Context;
use Test::Routine;
use Test::More;

{
    package t::MusicBrainz::Server::Context::TestCache1;
    use Moose;
    sub get { Storable::freeze(\'1') }
    sub set {}
    package t::MusicBrainz::Server::Context::TestCache2;
    use Moose;
    sub get { Storable::freeze(\'2') }
    sub set {}
}


test 'Check context CacheManager routing' => sub {
    my $test = shift;

    my $cache_manager = MusicBrainz::Server::CacheManager->new(
        profiles => {
            test1 => {
                class => 't::MusicBrainz::Server::Context::TestCache1',
                wrapped => 1,
                keys => ['foo'],
            },
            test2 => {
                class => 't::MusicBrainz::Server::Context::TestCache2',
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
};

1;
