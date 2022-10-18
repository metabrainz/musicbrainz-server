package t::MusicBrainz::Server::Context;
use strict;
use warnings;

use Test::Fatal;
use Test::Routine;
use Test::More;

{
    package t::MusicBrainz::Server::Context::TestCache1;
    use Moose;
    use namespace::autoclean;
    sub get { Storable::freeze(\'1') }
    sub set {}
    package t::MusicBrainz::Server::Context::TestCache2;
    use Moose;
    use namespace::autoclean;
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

test 'Can clear database connections and establish new ones' => sub {
    my $test = shift;

    my $c = MusicBrainz::Server::Context->create_script_context(database => 'READWRITE');

    $c->sql->begin;
    like exception { $c->sql->do('SELECT 1/0'); },
        qr/division by zero/i;
    like exception { $c->sql->do('SELECT 1') },
        qr/Current transaction is aborted/i;

    $c->connector->_disconnect;

    $c->sql->begin;
    is($c->sql->select_single_value('SELECT 1'), 1); # Fresh connection should work
    $c->sql->rollback;
};

1;
