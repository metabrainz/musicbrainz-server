package MusicBrainz::Schema;
use strict;
use warnings;

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';
use MusicBrainz::Schema::Loader;
use Sub::Exporter -setup => { exports => [qw( schema raw_schema )] };

my $readwrite = Databases->get_connection('READWRITE');
my $loader = MusicBrainz::Schema::Loader->new(
    dbh    => $readwrite->dbh,
    schema => $readwrite->database->schema
);

my $schema = $loader->make_schema;

# Weak references
$schema->add_foreign_key(
    Fey::FK->new(
        target_columns => [ $schema->table('artist')->column('id') ],
        source_columns => [
            $schema->table('editor_subscribe_artist')->column('artist') ],
    )
);

sub schema { $schema }

1;
