#!/usr/bin/env perl

use warnings;

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

my $dir = shift() || "$FindBin::Bin/../admin/sql";

print "Regenerating SQL scripts in $dir...\n";

sub process_tables
{
    open FILE, "<$dir/CreateTables.sql";
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
            if ($line =~ m/([a-z0-9_]+).*?\s*--.*?(weakly )?references ([a-z0-9_]+\.)?([a-z0-9_]+)\.([a-z0-9_]+)/i) {
                next if $2; # weak reference
                my @fk = ($1, ($3 || '') . $4, $5);
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

    open OUT, ">$dir/DropTables.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $table (@tables) {
        print OUT "DROP TABLE $table;\n";
    }
    close OUT;

    open FILE, "<$dir/CreateViews.sql";
    my $create_views_sql = do { local $/; <FILE> };
    close FILE;

    my @views;
    while ($create_views_sql =~ m/CREATE (?:OR REPLACE )?VIEW\s+([a-z0-9_]+)(.*?);/gsi) {
        my $name = $1;
        push @views, $name;
    }
    @views = sort(@views);

    open OUT, ">$dir/DropViews.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $view (@views) {
        print OUT "DROP VIEW $view;\n";
    }
    close OUT;

    open OUT, ">$dir/SetSequences.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $row (@sequences) {
        my ($table, $col) = @$row;
        print OUT "SELECT setval('${table}_${col}_seq', (SELECT MAX(${col}) FROM $table));\n";
    }
    close OUT;

    open OUT, ">$dir/CreateFKConstraints.sql";
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

    open OUT, ">$dir/DropFKConstraints.sql";
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

    open OUT, ">$dir/CreatePrimaryKeys.sql";
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

    open OUT, ">$dir/DropPrimaryKeys.sql";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $table (@tables) {
        next unless exists $primary_keys{$table};
        print OUT "ALTER TABLE $table DROP CONSTRAINT ${table}_pkey;\n";
    }
    close OUT;
}

process_tables("");

sub process_indexes
{
    my ($infile, $outfile) = @_;

    open FILE, "<$dir/$infile";
    my $create_indexes_sql = do { local $/; <FILE> };
    close FILE;

    my @indexes;
    while ($create_indexes_sql =~ m/CREATE .*?INDEX\s+([a-z0-9_]+)\s+/gi) {
        my $name = $1;
        push @indexes, $name;
    }
    @indexes = sort(@indexes);

    open OUT, ">$dir/$outfile";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $index (@indexes) {
        print OUT "DROP INDEX $index;\n";
    }
    close OUT;
}

process_indexes("CreateIndexes.sql", "DropIndexes.sql");
process_indexes("CreateSearchIndexes.sql", "DropSearchIndexes.sql");

sub process_functions
{
    my ($infile, $outfile) = @_;

    unless (-e "$dir/$infile") {
        print "Could not find $infile, skipping\n";
    }

    open FILE, "<$dir/$infile";
    my $create_functions_sql = do { local $/; <FILE> };
    close FILE;

    my @functions;
    while ($create_functions_sql =~ m/CREATE .*?FUNCTION\s+(.+?)\s+RETURNS/gi) {
        my $name = $1;
        push @functions, $name;
    }
    @functions = sort(@functions);

    my @aggregates;
    while ($create_functions_sql =~ m/CREATE\s+AGGREGATE\s+(\w+).*basetype[\s=]+(\w+)/gi) {
        push @aggregates, [$1, $2];
    }
    @aggregates = sort(@aggregates);

    open OUT, ">$dir/$outfile";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $func (@functions) {
        print OUT "DROP FUNCTION $func;\n";
    }
    foreach my $agg (@aggregates) {
        my ($name, $type) = @$agg;
        print OUT "DROP AGGREGATE $name ($type);\n";
    }
    close OUT;
}

process_functions("CreateFunctions.sql", "DropFunctions.sql");

sub process_triggers
{
    my ($infile, $outfile) = @_;

    unless (-e "$dir/$infile") {
        print "Could not find $infile, skipping\n";
    }

    open FILE, "<$dir/$infile";
    my $create_triggers_sql = do { local $/; <FILE> };
    close FILE;

    my @triggers;
    while ($create_triggers_sql =~ m/CREATE (?:CONSTRAINT )?TRIGGER\s+"?([a-z0-9_]+)"?\s+.*?\s+ON\s+"?([a-z0-9_]+)"?.*?;/gsi) {
        push @triggers, [$1, $2];
    }

    open OUT, ">$dir/$outfile";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    foreach my $trigger (@triggers) {
        print OUT "DROP TRIGGER $trigger->[0] ON $trigger->[1];\n";
    }
    close OUT;
}

process_triggers("CreateTriggers.sql", "DropTriggers.sql");
process_triggers("CreateReplicationTriggers.sql", "DropReplicationTriggers.sql");

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 Aurélien Mino

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
