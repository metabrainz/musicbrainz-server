package DBDefs;

use parent 'DBDefs::Default';
use MusicBrainz::Server::DatabaseConnectionFactory;

MusicBrainz::Server::DatabaseConnectionFactory->register_databases(
    MAINTENANCE => {
        database    => 'musicbrainz_db',
        host        => 'localhost',
        password    => '',
        port        => 5432,
        username    => 'musicbrainz',
    },
    READWRITE => {
        database    => 'musicbrainz_db',
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
);

sub DB_SCHEMA_SEQUENCE { 28 }

1;
