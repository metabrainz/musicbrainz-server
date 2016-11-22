package DBDefs;

use parent 'DBDefs::Default';
use MusicBrainz::Server::DatabaseConnectionFactory;

MusicBrainz::Server::DatabaseConnectionFactory->register_databases(
    SYSTEM => {
        database    => 'template1',
        host        => 'musicbrainz-test-database',
        password    => '',
        port        => 5432,
        username    => 'postgres',
    },
    TEST => {
        database    => 'musicbrainz_test',
        host        => 'musicbrainz-test-database',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
);

sub CACHE_MANAGER_OPTIONS {
    my $self = shift;
    my %CACHE_MANAGER_OPTIONS = (
        profiles => {
            external => {
                class => 'MusicBrainz::Server::CacheWrapper::Redis',
                options => {
                    server => 'musicbrainz-redis-cache:6379',
                    namespace => 'MB:',
                },
            },
        },
        default_profile => 'external',
    );

    return \%CACHE_MANAGER_OPTIONS
}

sub CATALYST_DEBUG { 0 }

sub DATASTORE_REDIS_ARGS {
    my $self = shift;
    return {
        database => 0,
        namespace => 'MB:',
        server => 'musicbrainz-redis-store:6379',
        test_database => 1,
    };
}

sub DB_SCHEMA_SEQUENCE { 23 }

sub DEVELOPMENT_SERVER { 0 }

sub GIT_INFO { return }

sub PLUGIN_CACHE_OPTIONS {
    my $self = shift;
    return {
        class => 'MusicBrainz::Server::CacheWrapper::Redis',
        server => 'musicbrainz-redis-cache:6379',
        namespace => 'MB:Catalyst:',
    };
}

1;
