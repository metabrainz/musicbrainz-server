package DBDefs;

use parent 'DBDefs::Default';
use MusicBrainz::Server::DatabaseConnectionFactory;

MusicBrainz::Server::DatabaseConnectionFactory->register_databases(
    # Selenium tests require READWRITE access.
    READWRITE => {
        database    => 'musicbrainz_test',
        host        => 'musicbrainz-test-database',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
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
    SELENIUM => {
        database    => 'musicbrainz_selenium',
        host        => 'musicbrainz-test-database',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
    TEST_JSON_DUMP => {
        database    => 'musicbrainz_test_json_dump',
        host        => 'musicbrainz-test-database',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
    TEST_FULL_EXPORT => {
        database    => 'musicbrainz_test_full_export',
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
                    namespace => $self->CACHE_NAMESPACE,
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
        namespace => $self->CACHE_NAMESPACE,
        server => 'musicbrainz-redis-store:6379',
        test_database => 1,
    };
}

sub DB_SCHEMA_SEQUENCE { 24 }

sub DB_STAGING_TESTING_FEATURES { 1 }

sub DEVELOPMENT_SERVER { 0 }

sub FORK_RENDERER { 0 }

sub GIT_BRANCH { return }

sub GIT_MSG { return }

sub GIT_SHA { return }

sub HTML_VALIDATOR { 'http://html5-validator:8888?out=json' }

sub MB_LANGUAGES { qw( de el-gr es-es et fi fr it ja nl en ) }

sub PLUGIN_CACHE_OPTIONS {
    my $self = shift;
    return {
        class => 'MusicBrainz::Server::CacheWrapper::Redis',
        server => 'musicbrainz-redis-cache:6379',
        namespace => $self->CACHE_NAMESPACE . 'Catalyst:',
    };
}

sub USE_SELENIUM_HEADER { 1 }

1;
