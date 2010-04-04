package MusicBrainz::Schema;
use strict;
use warnings;

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';
use MusicBrainz::Schema::Loader;
use Sub::Exporter -setup => { exports => [qw( schema raw_schema )] };

my ($schema, $raw_schema);

sub schema     { $schema     ||= _rw_schema()  }
sub raw_schema { $raw_schema ||= _raw_schema() }

sub _raw_schema {
    my $rawdata = Databases->get_connection('RAWDATA');
    my $loader = MusicBrainz::Schema::Loader->new(
        dbh    => $rawdata->dbh,
        schema => $rawdata->database->schema
    );

    my $schema = $loader->make_schema;
}

sub _rw_schema {
    my $readwrite = Databases->get_connection('READWRITE');
    my $loader = MusicBrainz::Schema::Loader->new(
        dbh    => $readwrite->dbh,
        schema => $readwrite->database->schema
    );

    my $schema = $loader->make_schema;

    # Weak references
    $schema->add_foreign_key($_) for
        Fey::FK->new(
            target_columns => [ $schema->table('artist')->column('id') ],
            source_columns => [
                $schema->table('editor_subscribe_artist')->column('artist') ],
        ),
        Fey::FK->new(
            target_columns => [ $schema->table('label')->column('id') ],
            source_columns => [
                $schema->table('editor_subscribe_label')->column('label') ],
        );

    return $schema;
}

1;
