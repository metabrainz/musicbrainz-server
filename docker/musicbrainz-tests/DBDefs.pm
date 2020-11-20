package DBDefs;

use parent 'DBDefs::Default';
use MusicBrainz::Server::DatabaseConnectionFactory;

MusicBrainz::Server::DatabaseConnectionFactory->register_databases(
    # Selenium tests require READWRITE access.
    READWRITE => {
        database    => 'musicbrainz_test',
        host        => 'localhost',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
    SYSTEM => {
        database    => 'template1',
        host        => 'localhost',
        password    => '',
        port        => 5432,
        username    => 'postgres',
    },
    TEST => {
        database    => 'musicbrainz_test',
        host        => 'localhost',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
    SELENIUM => {
        database    => 'musicbrainz_selenium',
        host        => 'localhost',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
    TEST_JSON_DUMP => {
        database    => 'musicbrainz_test_json_dump',
        host        => 'localhost',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
    TEST_FULL_EXPORT => {
        database    => 'musicbrainz_test_full_export',
        host        => 'localhost',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
    TEST_SITEMAPS => {
        database    => 'musicbrainz_test_sitemaps',
        host        => 'localhost',
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
                    server => 'localhost:6379',
                    namespace => $self->CACHE_NAMESPACE,
                },
            },
        },
        default_profile => 'external',
    );

    return \%CACHE_MANAGER_OPTIONS
}

sub CATALYST_DEBUG { 0 }

sub COVER_ART_ARCHIVE_ACCESS_KEY { 'hi_im_public' }
sub COVER_ART_ARCHIVE_SECRET_KEY { 'hi_im_private' }
sub COVER_ART_ARCHIVE_UPLOAD_PREFIXER { shift; sprintf('//localhost:5050/%s', shift) };
sub COVER_ART_ARCHIVE_DOWNLOAD_PREFIX { 'http://localhost:8081' };
sub COVER_ART_ARCHIVE_IA_METADATA_PREFIX { 'http://localhost:5050/metadata' }

sub DATASTORE_REDIS_ARGS {
    my $self = shift;
    return {
        database => 0,
        namespace => $self->CACHE_NAMESPACE,
        server => 'localhost:6379',
        test_database => 1,
    };
}

sub DB_SCHEMA_SEQUENCE { 26 }

sub DB_STAGING_TESTING_FEATURES { 1 }

sub DEVELOPMENT_SERVER { 0 }

sub FORK_RENDERER { 0 }

sub GIT_BRANCH { return }

sub GIT_MSG { return }

sub GIT_SHA { return }

sub HTML_VALIDATOR { 'http://localhost:8888?out=json' }

sub MB_LANGUAGES { qw( de el-gr es-es et fi fr it ja nl sq en ) }

sub ACTIVE_SCHEMA_SEQUENCE { 26 }

sub PLUGIN_CACHE_OPTIONS {
    my $self = shift;
    return {
        class => 'MusicBrainz::Server::CacheWrapper::Redis',
        server => 'localhost:6379',
        namespace => $self->CACHE_NAMESPACE . 'Catalyst:',
    };
}

sub SEARCH_SERVER { '127.0.0.1:8983/solr' }
sub SEARCH_ENGINE { 'SOLR' }

sub USE_SET_DATABASE_HEADER { 1 }

# CircleCI sets `NO_PROXY=127.0.0.1,localhost` in every container,
# so the Selenium proxy doesn't work unless we make requests against
# a different hostname alias.
sub WEB_SERVER { 'mbtest:5000' }
sub STATIC_RESOURCES_LOCATION { '//mbtest:5000/static/build' }

1;
