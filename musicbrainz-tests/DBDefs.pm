package DBDefs;

use base 'DBDefs::Default';
use MusicBrainz::Server::DatabaseConnectionFactory;
use MusicBrainz::Server::Replication ':replication_type';

MusicBrainz::Server::DatabaseConnectionFactory->register_databases(
    MAINTENANCE => {
        database    => 'musicbrainz_db',
        schema      => 'musicbrainz',
        username    => 'musicbrainz',
        host        => 'localhost',
        port        => 5432,
    },
    SYSTEM => {
        database    => 'template1',
        schema      => '',
        username    => 'Michael',
        host        => 'localhost',
        port        => 5432,
    },
    TEST => {
        database    => 'musicbrainz_test',
        schema      => 'musicbrainz',
        username    => 'musicbrainz',
        host        => 'localhost',
        port        => 5432,
    },
    READWRITE => {
        database    => 'musicbrainz_db',
        schema      => 'musicbrainz',
        username    => 'musicbrainz',
        host        => 'localhost',
        port        => 5432,
    },
);

sub CATALYST_DEBUG { 0 }
sub DB_SCHEMA_SEQUENCE { 23 }
sub DB_STAGING_TESTING_FEATURES { 0 }
sub DEVELOPMENT_SERVER { 0 }
sub HTML_VALIDATOR { 'http://html5-validator:8888?out=json' }
sub REDIS_SERVER { '172.19.0.5:6379' }
sub REPLICATION_TYPE { RT_STANDALONE }

1;
