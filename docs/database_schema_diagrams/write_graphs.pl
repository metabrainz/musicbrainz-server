#!/usr/bin/env perl

use utf8;
use open ':std', ':encoding(UTF-8)';
use warnings;
use strict;
use English;

################################################################################

=head1 NAME

write_graphs.pl - Write DOT files
                  from PostgreSQL table creation files
                  (under '../../admin/sql/' and its subdirectories)
                  and JSON diagram definition files given in arguments
                  (under './source/' directory)

=head1 SYNOPSIS

write_graphs.pl [options] JSON_FILES...

Options:

    -h, --help                          show this help
    -d, --output-dir DIR                use DIR to write output DOT files under
                                        default: '.'

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

################################################################################

use File::Basename qw( basename );
use FindBin;
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

my $help_flag;
my $output_dir = '.';

GetOptions(
    'output-dir|d=s'            => \$output_dir,
    'help|h'                    => \$help_flag,
);

pod2usage() if $help_flag;

my @diagram_ids;
for my $arg (@ARGV) {
    my $diagram_id = basename($arg, '.json');
    pod2usage(
        -exitval => 64, # EX_USAGE
        -message => "$FindBin::Script: unrecognized argument: $arg",
    ) if not -f "$FindBin::Bin/source/$diagram_id.json";
    push @diagram_ids, $diagram_id;
}

################################################################################

use lib "$FindBin::Bin/../../lib";

use Cwd qw( realpath );
use File::Slurp qw( read_file );
use JSON::XS qw( decode_json );
use List::AllUtils qw( any );
use MusicBrainz::Server::Data::Utils qw( contains_string );
use MusicBrainz::Server::Log qw( log_error log_info log_warning );
use Readonly;

Readonly my $DEF_DIR => realpath("$FindBin::Bin/source");
Readonly my $SQL_DIR => realpath("$FindBin::Bin/../../admin/sql");
Readonly my $OUTPUT_DIR => realpath($output_dir);

Readonly my $DB_SCHEMA_SEQUENCE => 30;

Readonly my $TABLE_FONT_SIZE => '17';
Readonly my $COLUMN_FONT_SIZE => '14';

# Pastel background colors 25% lighter than official colors
# Avoid using alpha layer to avoid darkening by overlay
Readonly my $CAA_COLOR => '#35a8b3';
Readonly my $MEB_COLOR => '#f0976c';
Readonly my $MB_COLOR => '#cb75ab';

Readonly my $HI_TABLE_COLOR => '#eeeeeebb';
Readonly my $TABLE_COLOR => '#bbbbbb77';

Readonly my $PK_COLUMN_COLOR => '#eeeeee77';
Readonly my $FK_COLUMN_COLOR => '#eeeeee55';
Readonly my $COLUMN_COLOR => '#bbbbbb33';

Readonly my %SCHEMA_COLOR => (
  'cover_art_archive' => $CAA_COLOR,
  'event_art_archive' => $CAA_COLOR,
  'musicbrainz' => $MEB_COLOR
);

################################################################################

my %created_schemas;
my @created_tables;
my %created_columns;
my %created_foreign_keys;
my %created_primary_keys;
my %diagram_defs;

for my $diagram_id (sort @diagram_ids) {
    my $def_filepath = "$DEF_DIR/$diagram_id.json";
    log_info { "Parsing diagram definition file '$def_filepath'..." };
    $diagram_defs{$diagram_id} = decode_json(read_file("$def_filepath"));
}

################################################################################

sub parse_tables
{
    my $infile_path = "$SQL_DIR/" . shift();
    unless (-e "$infile_path") {
        log_warning { "Could not find '$infile_path', skipping" };
        return;
    }
    open my $infile_handle, '<', "$infile_path";
    my $infile_content = do { local $INPUT_RECORD_SEPARATOR; <$infile_handle> };
    close $infile_handle;
    my $search_path = 'musicbrainz';
    if ($infile_content =~ /(?:^|\n)\s*SET\s+search_path\s+=\s+'?([a-z_]+)'?\s*(?:,[^;]+\s*)?;\s*(?:\n|$)/i) {
        $search_path = $1;
    }
    my @tables;
    while ($infile_content =~ m/CREATE TABLE\s+([a-z0-9_]+)\s+\(\s*(?:-- replicate(?: ?\(verbose\))?)?\s*(.*?)\s*\);/gsi) {
        my $table_name = $1;
        my $full_table_name = "$search_path.$table_name";
        my @lines = split /\n/, $2;
        my @cols;
        my @fks;
        foreach my $line (@lines) {
            # Assume that multiline constraints starting on a separate line are not followed by any column definition
            last if $line =~ /^\s*(CHECK|CONSTRAINT)\b/;

            if ($line =~ /^\s*([a-z0-9_]+)\s+.*/) {
                my $col_name = $1;
                push @cols, $col_name;
            }

            if ($line =~ m/([a-z0-9_]+).*?\s*-- (?:PK, |FK, )?(?:weakly )?(?:separately )?references ([a-z0-9_]+\.)?([a-z0-9_]+)\.([a-z0-9_]+)/i) {
                # Assume that schema is specified but in admin/sql/CreateTables.sql
                my @fk = ($1, ($2 // 'musicbrainz.') . $3, $4);
                push @fks, [@fk];
            }
        }
        if (@cols) {
            $created_columns{$full_table_name} = \@cols;
        }
        if (@fks) {
            $created_foreign_keys{$full_table_name} = \@fks;
        }
        my @pks;
        foreach my $line (@lines) {
            if ($line =~ m/([a-z0-9_]+).*?\s*--.*?PK/i || $line =~ m/([a-z0-9_]+).*?SERIAL/i) {
                push @pks, $1;
            }
        }
        if (@pks) {
            $created_primary_keys{$full_table_name} = \@pks;
        }
        push @created_tables, $full_table_name;
        push @tables, $full_table_name;
    }
    @created_tables = sort(@created_tables);
    $created_schemas{$search_path} = \@tables;
}

sub write_dot_files
{
    my $diagram_id = shift();

    my $diagram_tooltip = $diagram_defs{$diagram_id}{'tooltip'};
    my $diagram_tables_props = $diagram_defs{$diagram_id}{'tables'};
    my @diagram_tables_names = sort keys %$diagram_tables_props;

    my %diagram_foreign_keys;
    foreach my $table (@diagram_tables_names) {
        next unless exists $created_foreign_keys{$table};
        my @cfks = @{$created_foreign_keys{$table}};
        my @dfks;
        foreach my $cfk (@cfks) {
            my $ref_table = $cfk->[1];
            if (contains_string(\@diagram_tables_names, $ref_table)) {
                push @dfks, $cfk;
            }
        }
        $diagram_foreign_keys{$table} = \@dfks if (@dfks);
    }

    my %diagram_columns;
    foreach my $table (@diagram_tables_names) {
        unless (contains_string(\@created_tables, $table)) {
            log_warning { "The table '$table' in '$diagram_id' diagram doesn't exist." };
        }
        if (contains_string($diagram_tables_props->{$table}, 'shortened')) {
            my $is_any_column_hidden = 0;
            my @columns;
            if (exists $created_primary_keys{$table}) {
                @columns = @{$created_primary_keys{$table}};
            }
            if (exists $diagram_foreign_keys{$table}) {
                @columns = (
                    @columns,
                    map { $_->[0] } @{ $diagram_foreign_keys{$table} }
                );
            }
            foreach my $foreign_table (@diagram_tables_names) {
                next unless $table eq $foreign_table;
                next unless exists $diagram_foreign_keys{$foreign_table};
                my @referenced_columns =
                    map { $_->[2] }
                    grep { $_->[1] eq $table }
                    @{$diagram_foreign_keys{$table}};
                @columns = (@columns, @referenced_columns);
            }
            if (@columns) {
                my @sorted_columns;
                foreach my $column (@{ $created_columns{$table} }) {
                    if (contains_string(\@columns, $column)) {
                      push @sorted_columns, $column;
                    } else {
                      $is_any_column_hidden = 1;
                    }
                }
                if ($is_any_column_hidden) {
                  push @sorted_columns, '...';
                }
                $diagram_columns{$table} = \@sorted_columns;
            }
        } else {
            if ($created_columns{$table}) {
                $diagram_columns{$table} = $created_columns{$table};
            }
            next
        }
    }

    open my $graph_fh, '>', "$OUTPUT_DIR/$diagram_id.dot";
    print $graph_fh <<~"EOF";
        // Automatically generated, do not edit.
        // - Database schema sequence: $DB_SCHEMA_SEQUENCE
        digraph $diagram_id {
            tooltip = "$diagram_tooltip"
            graph [
                bgcolor = "$MB_COLOR:$MEB_COLOR"
                concentrate = true
                gradientangle = 330
                pack = true
                rankdir = "LR"
            ];
            node [
                shape = plain
            ];

            // Tables
        EOF

    foreach my $table (@diagram_tables_names) {
        my $bgcolor =
          (contains_string($diagram_tables_props->{$table}, 'highlighted'))
          ? "$HI_TABLE_COLOR" : "$TABLE_COLOR";
        my $short_table_name = (split /\./, $table)[1];
        my $title =
          (contains_string($diagram_tables_props->{$table}, 'materialized'))
          ? "$short_table_name (m)" : "$short_table_name";
        print $graph_fh <<~"EOF";
                "$table" [
                    label = <
                        <table border="0" cellspacing="0" cellborder="1">
                            <tr><td bgcolor="$bgcolor"><font point-size="$TABLE_FONT_SIZE">$title</font></td></tr>
            EOF
        if (exists $diagram_columns{$table}) {
            my @column_names = @{ $diagram_columns{$table} };
            foreach my $col (@column_names) {
                if (contains_string($created_primary_keys{$table}, $col)) {
                    print $graph_fh <<~"EOF";
                                    <tr><td bgcolor="$PK_COLUMN_COLOR" align="left" port="$col"><font point-size="$COLUMN_FONT_SIZE"><u>$col</u></font></td></tr>
                    EOF
                } elsif (any { $_->[0] eq $col } @{ $diagram_foreign_keys{$table} }) {
                    print $graph_fh <<~"EOF";
                                    <tr><td bgcolor="$FK_COLUMN_COLOR" align="left" port="$col"><font point-size="$COLUMN_FONT_SIZE">$col</font></td></tr>
                    EOF
                } else {
                    print $graph_fh <<~"EOF";
                                    <tr><td bgcolor="$COLUMN_COLOR" align="left" port="$col"><font point-size="$COLUMN_FONT_SIZE">$col</font></td></tr>
                    EOF
                }
            }
        }
        print $graph_fh <<~"EOF";
                        </table>
                    >
                ];
            EOF
    }

    # Schemas
    my %diagram_schemas;
    foreach my $schema (keys %created_schemas) {
        my @schema_tables;
        foreach my $table (@diagram_tables_names) {
            if (contains_string($created_schemas{$schema}, $table)) {
                push @schema_tables, $table;
            }
        }
        $diagram_schemas{$schema} = \@schema_tables if @schema_tables;
    }
    if (keys %diagram_schemas > 1) {
        print $graph_fh "\n  // Schemas other than 'musicbrainz'\n";
        foreach my $schema (keys %diagram_schemas) {
            next unless $schema ne 'musicbrainz';
            my $current_schema_color = $SCHEMA_COLOR{$schema};
            print $graph_fh <<~"EOF";
                    subgraph cluster_$schema {
                        bgcolor = "$current_schema_color:$MEB_COLOR"

                EOF
            foreach my $table (@{ $diagram_schemas{$schema} }) {
                print $graph_fh <<~"EOF";
                            "$table";
                    EOF
            }
            print $graph_fh <<~"EOF";
                    }
                EOF
        }
    }

    # References
    if (keys %diagram_foreign_keys) {
        print $graph_fh "\n    // References\n";
        foreach my $table (@diagram_tables_names) {
            next unless exists $diagram_foreign_keys{$table};
            my @fks = @{$diagram_foreign_keys{$table}};
            foreach my $fk (@fks) {
                my ($col, $ref_table, $ref_col) = @$fk;
                unless ($ref_table eq $table) {
                    print $graph_fh "    \"$table\":\"$col\" -> \"$ref_table\":\"$ref_col\"\n";
                }
            }
        }
        print $graph_fh "}\n";
    } else {
        log_warning { "No reference for '$diagram_id', skipping." };
    }
    close $graph_fh;
}

################################################################################

log_info { 'Parsing SQL files...' };

parse_tables('CreateTables.sql');
parse_tables('caa/CreateTables.sql');
parse_tables('eaa/CreateTables.sql');

log_info { "Generating DOT files in '$OUTPUT_DIR/'..." };

foreach my $diagram_id (sort keys %diagram_defs) {
    write_dot_files($diagram_id);
}

log_info { 'All done.' };
