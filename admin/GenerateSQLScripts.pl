#!/usr/bin/env perl

use utf8;
use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

my $dir = shift() || "$FindBin::Bin/../admin/sql";

print "Regenerating SQL scripts in $dir...\n";

sub find_search_path
{
    my $search_path = '';
    my $infile = "CreateTables.sql";
    unless (-e "$dir/$infile") {
        print "Could not find $infile, search_path might not be correct\n";
        return $search_path;
    }
    open FILE, "<$dir/CreateTables.sql";
    while (<FILE>) {
        if ($_ =~ /^SET search_path = .*$/) {
            $search_path = $_ . "\n";
            last;
        }
    }
    close FILE;
    return $search_path;
}

my $search_path = find_search_path();

sub process_tables
{
    my $infile = "CreateTables.sql";
    unless (-e "$dir/$infile") {
        print "Could not find $infile, skipping\n";
        return;
    }
    open FILE, "<$dir/$infile";
    my $create_tables_sql = do { local $/; <FILE> };
    close FILE;

    my @tables;
    my %foreign_keys;
    my %primary_keys;
    my @sequences;
    my @replication_triggers;
    while ($create_tables_sql =~ m/CREATE TABLE\s+([a-z0-9_]+)\s+\(\s*(-- replicate(?: ?\(verbose\))?)?\s*(.*?)\s*\);/gsi) {
        my $name = $1;
        my $replicate = $2;
        my @lines = split /\n/, $3;
        my @fks;
        foreach my $line (@lines) {
            if ($line =~ m/([a-z0-9_]+).*?\s*-- (?:PK, |FK, )?(weakly |separately )?references ([a-z0-9_]+\.)?([a-z0-9_]+)\.([a-z0-9_]+)/i) {
                next if (defined $2 && $2 eq 'weakly '); # weak reference
                my @fk = ($1, ($3 || '') . $4, $5);
                my $cascade = ($line =~ m/CASCADE/) ? 1 : 0;
                my $drop_only = $2;
                push @fks, [@fk, $cascade, $drop_only];
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
        if ($replicate) {
            if ($replicate =~ m/\(verbose\)/) {
                push @replication_triggers, [$name, 1];
            } else {
                push @replication_triggers, [$name, 0];
            }
        }
        push @tables, $name;
    }
    @tables = sort(@tables);
    @replication_triggers = sort { $a->[0] cmp $b->[0] } @replication_triggers;

    open my $drop_fh, ">$dir/DropTables.sql";
    open my $trunc_fh, ">$dir/TruncateTables.sql";
    print $_ "-- Automatically generated, do not edit.\n" for $drop_fh, $trunc_fh;
    print $drop_fh "\\unset ON_ERROR_STOP\n\n";
    print $trunc_fh "\\set ON_ERROR_STOP 1\n\n";
    if ($search_path) {
        print $_ $search_path for $drop_fh, $trunc_fh;
    }
    foreach my $table (@tables) {
        print $drop_fh "DROP TABLE $table;\n";
        print $trunc_fh "TRUNCATE TABLE $table RESTART IDENTITY CASCADE;\n";
    }
    close $drop_fh;
    close $trunc_fh;

    if (-e "$dir/CreateViews.sql") {
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
        print OUT $search_path if $search_path;
        foreach my $view (@views) {
            print OUT "DROP VIEW $view;\n";
        }
        close OUT;
    } else {
        print "Could not find CreateViews.sql, skipping\n";
    }

    if (@sequences) {
        open OUT, ">$dir/SetSequences.sql";
        print OUT "-- Automatically generated, do not edit.\n";
        print OUT "\\unset ON_ERROR_STOP\n\n";
        print OUT $search_path if $search_path;
        foreach my $row (@sequences) {
            my ($table, $col) = @$row;
            print OUT "SELECT setval('${table}_${col}_seq', COALESCE((SELECT MAX(${col}) FROM $table), 0) + 1, FALSE);\n";
        }
        close OUT;
    }

    if (keys %foreign_keys) {
        open OUT, ">$dir/CreateFKConstraints.sql";
        print OUT "-- Automatically generated, do not edit.\n";
        print OUT "\\set ON_ERROR_STOP 1\n\n";
        print OUT $search_path if $search_path;
        foreach my $table (@tables) {
            next unless exists $foreign_keys{$table};
            my @fks = @{$foreign_keys{$table}};
            foreach my $fk (@fks) {
                unless ($fk->[4]) {
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
        }
        close OUT;

        open OUT, ">$dir/DropFKConstraints.sql";
        print OUT "-- Automatically generated, do not edit.\n";
        print OUT "\\unset ON_ERROR_STOP\n\n";
        print OUT $search_path if $search_path;
        foreach my $table (@tables) {
            next unless exists $foreign_keys{$table};
            my @fks = @{$foreign_keys{$table}};
            foreach my $fk (@fks) {
                my $col = $fk->[0];
                print OUT "ALTER TABLE $table DROP CONSTRAINT IF EXISTS ${table}_fk_${col};\n";
            }
        }
        close OUT;
    } else {
        print "No foreign keys, skipping\n";
    }


    if (keys %primary_keys) {
        open OUT, ">$dir/CreatePrimaryKeys.sql";
        print OUT "-- Automatically generated, do not edit.\n";
        print OUT "\\set ON_ERROR_STOP 1\n\n";
        print OUT $search_path if $search_path;
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
        print OUT $search_path if $search_path;
        foreach my $table (@tables) {
            next unless exists $primary_keys{$table};
            print OUT "ALTER TABLE $table DROP CONSTRAINT IF EXISTS ${table}_pkey;\n";
        }
        close OUT;
    } else {
        print "No primary keys, skipping\n";
    }

    if (scalar @replication_triggers) {
        my $replication_search_path = $search_path;
        $replication_search_path =~ s/;/, musicbrainz, public;/;
        open OUT, ">$dir/CreateReplicationTriggers.sql";
        print OUT "-- Automatically generated, do not edit.\n";
        print OUT "\\set ON_ERROR_STOP 1\n\n";
        print OUT $replication_search_path if $replication_search_path;
        print OUT "BEGIN;\n\n";
        foreach my $row (@replication_triggers) {
            my ($table, $verbose) = @$row;
            print OUT "CREATE TRIGGER \"reptg_$table\"\n";
            print OUT "AFTER INSERT OR DELETE OR UPDATE ON \"$table\"\n";
            print OUT "FOR EACH ROW EXECUTE PROCEDURE \"recordchange\" (" . ($verbose ? "'verbose'" : "") . ");\n\n"
        }
        print OUT "COMMIT;\n";
        close OUT;
    }
}

process_tables("");

sub process_indexes
{
    my ($infile, $outfile) = @_;

    unless (-e "$dir/$infile") {
        print "Could not find $infile, skipping\n";
        return;
    }

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
    print OUT $search_path if $search_path;
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
        return;
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
    print OUT $search_path if $search_path;
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
        return;
    }

    open FILE, "<$dir/$infile";
    my $create_triggers_sql = do { local $/; <FILE> };
    close FILE;

    my @triggers;
    while ($create_triggers_sql =~ m/CREATE (?:CONSTRAINT )?TRIGGER\s+"?([a-z0-9_]+)"?\s+.*?\s+ON\s+"?([a-z0-9_\.]+)"?.*?;/gsi) {
        push @triggers, [$1, $2];
    }

    open OUT, ">$dir/$outfile";
    print OUT "-- Automatically generated, do not edit.\n";
    print OUT "\\unset ON_ERROR_STOP\n\n";
    print OUT $search_path if $search_path;
    foreach my $trigger (@triggers) {
        print OUT "DROP TRIGGER $trigger->[0] ON $trigger->[1];\n";
    }
    close OUT;
}

process_triggers("CreateTriggers.sql", "DropTriggers.sql");
process_triggers("CreateReplicationTriggers.sql", "DropReplicationTriggers.sql");

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 Aurélien Mino

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
