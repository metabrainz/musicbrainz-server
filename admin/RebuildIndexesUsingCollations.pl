#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use Getopt::Long qw( GetOptions );
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server::Context;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

my $database = 'MAINTENANCE';
my $concurrently = 1;
my $show_help = 0;

sub usage {
    print <<~EOF;
        Usage: RebuildIndexesUsingCollations.pl [options]

        Rebuild all indexes using collations,
        as needed in case of a version mismatch after an update of glibc or libicu.

        Options:
            --database          database to connect to (default: MAINTENANCE)
            --[no]concurrently  enable or disable concurrent reindexing
                                (concurrent is slower but doesn't lock any table)
                                (default: enabled)
            --help              show this help
        EOF
}

GetOptions(
    'database=s'    => \$database,
    'concurrently!' => \$concurrently,
    'help'          => \$show_help,
) or usage(), exit 2;

usage(), exit if $show_help;

my $c = MusicBrainz::Server::Context->create_script_context(database => $database);
my $dbh = $c->dbh;

my $indexes = $c->sql->select_list_of_hashes(<<~SQL);
    SELECT n.nspname AS schema_name, i.relname AS index_name
      FROM pg_index AS idx
      JOIN pg_class AS c ON idx.indrelid = c.oid
      JOIN pg_class AS i ON idx.indexrelid = i.oid
      JOIN pg_namespace AS n ON n.oid = c.relnamespace
      JOIN pg_attribute AS a ON (a.attnum = any(idx.indkey) AND a.attrelid = c.oid)
      JOIN pg_collation AS col ON a.attcollation = col.oid
     WHERE col.collname IN ('default', 'musicbrainz')
    ORDER BY n.nspname, i.relname
    SQL

for my $index (@$indexes) {
    my $schema_name = $dbh->quote_identifier($index->{schema_name});
    my $index_name = $dbh->quote_identifier($index->{index_name});

    my $reindex_cmd = 'REINDEX INDEX ' .
        ($concurrently ? 'CONCURRENTLY ' : '') .
        "$schema_name.$index_name;";

    print "$reindex_cmd\n";

    $c->sql->auto_commit(1);
    $c->sql->do($reindex_cmd);
}

$c->sql->auto_commit;
$c->sql->do('ALTER COLLATION musicbrainz.musicbrainz REFRESH VERSION');
