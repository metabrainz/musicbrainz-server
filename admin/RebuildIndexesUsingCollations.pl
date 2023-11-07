#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context(database => 'MAINTENANCE');
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
    my $reindex_cmd = "REINDEX INDEX CONCURRENTLY $schema_name.$index_name;";
    print "$reindex_cmd\n";
    $c->sql->auto_commit(1);
    $c->sql->do($reindex_cmd);
}
