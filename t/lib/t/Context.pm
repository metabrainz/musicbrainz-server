package t::Context;
use Moose::Role;
use namespace::autoclean;

use Carp qw( confess );
use DBDefs;
use File::Temp;
use MusicBrainz::DataStore::Redis;
use MusicBrainz::Server::Test;

has c => (
    is => 'ro',
    builder => '_build_context',
);

has cache_aware_c => (
    is => 'ro',
    builder => '_build_cache_aware_context',
    clearer => '_clear_cache_aware_c',
    predicate => '_has_cache_aware_c',
    lazy => 1,
);

sub _build_context {
    MusicBrainz::Server::Test->create_test_context();
}

sub _build_cache_aware_context {
    my $test = shift;

    my $cache_opts = DBDefs->CACHE_MANAGER_OPTIONS;
    my $store_opts = DBDefs->DATASTORE_REDIS_ARGS;

    $cache_opts->{profiles}{external}{options}{namespace} = 'mbtest:';
    $cache_opts->{profiles}{external}{options}{database} =
        DBDefs->REDIS_TEST_DATABASE;
    $store_opts->{database} =
        DBDefs->REDIS_TEST_DATABASE;

    return $test->c->meta->clone_object(
        $test->c,
        cache_manager =>
            MusicBrainz::Server::CacheManager->new(%$cache_opts),
        store => MusicBrainz::DataStore::Redis->new(%$store_opts),
        models => {}, # Need to reload models to use this new $c
        fresh_connector => 1,
    );
}

around run_test => sub {
    my $orig = shift;
    my $self = shift;

    MusicBrainz::Server::Test->prepare_test_server;

    my $c = $self->c;

    $c->connector->_disconnect;

    $c->sql->begin;

    $self->$orig(@_);

    if ($c->sql->transaction_depth > 1 ||
        $c->sql->transaction_depth > 1) {
        confess('Transactions still open after test complete');
    }

    $c->sql->rollback;

    if ($self->_has_cache_aware_c) {
        my $cache_aware_c = $self->cache_aware_c;
        $cache_aware_c->cache->clear;
        $cache_aware_c->store->clear;
    }
};

1;
