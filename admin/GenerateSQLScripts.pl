#!/usr/bin/env perl

use warnings;

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

sub process_tables
{
    my ($dir) = @_;

    open FILE, "<$FindBin::Bin/../admin/sql$dir/CreateTables.sql";
    my $create_tables_sql = do { local $/; <FILE> };
    close FILE;

    my @tables;
    my %foreign_keys;
    my %primary_keys;
    my @sequences;
    while ($create_tables_sql =~ m/CREATE TABLE\s+([a-z0-9_]+)\s+\(\s*(.*?)\s*\);/gsi) {
        my $name = $1;
        my @lines = split /\n/, $2;
        my @fks;
        foreach my $line (@lines) {
            if ($line =~ m/([a-z0-9_]+).*?\s*--.*?references ([a-z0-9_]+)\.([a-z0-9_]+)/i) {
                my @fk = ($1, $2, $3);
                my $cascade = ($line =~ m/CASCADE/) ? 1 : 0;
                push @fks, [@fk, $cascade];
            }
        }
        if (@fks) {
            $foreign_keys{$name} = \@fks;
        }
        my @pks;
        foreach my $line (@lines) {
            if ($line =~ m/([a-z0-9_]+).*?\s*--.*?PK/i || $line =~ m/([a-z0-9_]+).*?SERIAL/i) {
                push @pks, $1;
            }
            if ($line =~ m/([a-z0-9_]+).*?SERIAL/i) {
                push @sequences, [$name, $1];
            }
        }
        if (@pks) {
            $primary_keys{$name} = \@pks;
        }
        push @tables, $name;
    }
    @tables = sort(@tables);

    open OUT, ">$FindBin::Bin/../admin/sql$dir/DropTables.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $table (@tables) {
        print OUT "DROP TABLE $table;\n";
    }
    close OUT;

    open OUT, ">$FindBin::Bin/../admin/sql$dir/SetSequences.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $row (@sequences) {
        my ($table, $col) = @$row;
        print OUT "SELECT setval('${table}_${col}_seq', (SELECT MAX(${col}) FROM $table));\n";
    }
    close OUT;

    open OUT, ">$FindBin::Bin/../admin/sql$dir/CreateFKConstraints.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\set ON_ERROR_STOP 1\n\n";
    foreach my $table (@tables) {
        next unless exists $foreign_keys{$table};
        my @fks = @{$foreign_keys{$table}};
        foreach my $fk (@fks) {
            my $col = $fk->[0];
            my $ref_table = $fk->[1];
            my $ref_col = $fk->[2];
            print OUT "ALTER TABLE $table\n";
            print OUT "   ADD CONSTRAINT ${table}_fk_${col}\n";
            print OUT "   FOREIGN KEY ($col)\n";
            print OUT "   REFERENCES $ref_table($ref_col)";
            if ($fk->[3]) {
                print OUT "\n   ON DELETE CASCADE;\n\n";
            }
            else {
                print OUT ";\n\n";
            }
        }
    }
    close OUT;

    open OUT, ">$FindBin::Bin/../admin/sql$dir/DropFKConstraints.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $table (@tables) {
        next unless exists $foreign_keys{$table};
        my @fks = @{$foreign_keys{$table}};
        foreach my $fk (@fks) {
            my $col = $fk->[0];
            print OUT "ALTER TABLE $table DROP CONSTRAINT ${table}_fk_${col};\n";
        }
    }
    close OUT;

    open OUT, ">$FindBin::Bin/../admin/sql$dir/CreatePrimaryKeys.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\set ON_ERROR_STOP 1\n\n";
    foreach my $table (@tables) {
        next unless exists $primary_keys{$table};
        my @pks = @{$primary_keys{$table}};
        my $cols = join ", ", @pks;
        print OUT "ALTER TABLE $table ADD CONSTRAINT ${table}_pkey ";
        print OUT "PRIMARY KEY ($cols);\n";
    }
    close OUT;

    open OUT, ">$FindBin::Bin/../admin/sql$dir/DropPrimaryKeys.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $table (@tables) {
        next unless exists $primary_keys{$table};
        print OUT "ALTER TABLE $table DROP CONSTRAINT ${table}_pkey;\n";
    }
    close OUT;
}

process_tables("");
process_tables("/vertical/rawdata");

sub process_indexes
{
    my ($infile, $outfile) = @_;

    open FILE, "<$FindBin::Bin/../admin/sql/$infile";
    my $create_indexes_sql = do { local $/; <FILE> };
    close FILE;

    my @indexes;
    while ($create_indexes_sql =~ m/CREATE .*?INDEX\s+([a-z0-9_]+)\s+/gi) {
        my $name = $1;
        push @indexes, $name;
    }
    @indexes = sort(@indexes);

    open OUT, ">$FindBin::Bin/../admin/sql/$outfile";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $index (@indexes) {
        print OUT "DROP INDEX $index;\n";
    }
    close OUT;
}

process_indexes("CreateIndexes.sql", "DropIndexes.sql");
process_indexes("CreateSearchIndexes.sql", "DropSearchIndexes.sql");
process_indexes("vertical/rawdata/CreateIndexes.sql", "vertical/rawdata/DropIndexes.sql");

sub process_functions
{
    my ($infile, $outfile) = @_;

    open FILE, "<$FindBin::Bin/../admin/sql/$infile";
    my $create_functions_sql = do { local $/; <FILE> };
    close FILE;

    my @functions;
    while ($create_functions_sql =~ m/CREATE .*?FUNCTION\s+(.+?)\s+RETURNS/gi) {
        my $name = $1;
        push @functions, $name;
    }
    @functions = sort(@functions);

    my @aggregates;
    while ($create_functions_sql =~ m/CREATE\s+AGGREGATE\s+(\w+)/gi) {
        my $name = $1;
        push @aggregates, $name;
    }
    @aggregates = sort(@aggregates);

    open OUT, ">$FindBin::Bin/../admin/sql/$outfile";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $func (@functions) {
        print OUT "DROP FUNCTION $func;\n";
    }
    foreach my $agg (@aggregates) {
        print OUT "DROP AGGREGATE $agg;\n";
    }
    close OUT;
}

process_functions("CreateFunctions.sql", "DropFunctions.sql");
process_functions("vertical/rawdata/CreateFunctions.sql",
                  "vertical/rawdata/DropFunctions.sql");

open FILE, "<$FindBin::Bin/../admin/sql/CreateTriggers.sql";
my $create_triggers_sql = do { local $/; <FILE> };
close FILE;

my @triggers;
while ($create_triggers_sql =~ m/CREATE TRIGGER\s+([a-z0-9_]+)\s+.*?\s+ON\s+([a-z0-9_]+)/gi) {
    push @triggers, [$1, $2];
}

open OUT, ">$FindBin::Bin/../admin/sql/DropTriggers.sql";
print OUT "-- Automatically generated, do not edit.\n";
print OUT "\\unset ON_ERROR_STOP\n\n";
foreach my $trigger (@triggers) {
    print OUT "DROP TRIGGER $trigger->[0] ON $trigger->[1];\n";
}
close OUT;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
