#!/usr/bin/env perl

# MBS-1799, Add ISO 639-3 language codes to the database

use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";
use Text::Trim qw( trim );

use MusicBrainz::Server::Context;

open(my $import, '<', "$Bin/../../misc/iso-639-3_20120228.tab");

my $c = MusicBrainz::Server::Context->create_script_context;

$c->sql->begin;

my $row = $c->sql->select_single_row_hash ("SELECT * FROM language LIMIT 1");

die "run 20120405-rename-lagnuage-columns.sql first.\n" unless exists $row->{iso_code_3};

my $count = 0;
while (<$import>)
{
    my @columns = split /\t/;

    next unless $columns[0] =~ m/[a-z][a-z][a-z]/;

    my %data = (
        iso_code_3 => $columns[0],
        iso_code_2b => $columns[1],
        iso_code_2t => $columns[2],
        iso_code_1 => $columns[3],
        name => $columns[6]
    );

    $data{iso_code_1} = undef if trim($data{iso_code_1}) eq "";
    $data{iso_code_2b} = undef if trim($data{iso_code_2b}) eq "";
    $data{iso_code_2t} = undef if trim($data{iso_code_2t}) eq "";

    my $exists = 0;
    if (defined $data{iso_code_2b} || defined $data{iso_code_2t})
    {
        $exists = $c->sql->select_single_row_hash (
            "SELECT * FROM language ".
            "WHERE iso_code_2b = ? OR iso_code_2t = ?",
            $data{iso_code_2b}, $data{iso_code_2t});
    }
    else
    {
        $exists = $c->sql->select_single_row_hash (
            "SELECT * FROM language ".
            "WHERE iso_code_3 = ?",
            $data{iso_code_3});
    }

    if ($exists)
    {
        $exists->{iso_code_2b} = undef if trim($exists->{iso_code_2b} // "") eq "";
        $exists->{iso_code_2t} = undef if trim($exists->{iso_code_2t} // "") eq "";

        if (defined $data{iso_code_2b} &&
            defined $data{iso_code_2t} &&
            ($data{iso_code_2b} ne $exists->{iso_code_2b} || $data{iso_code_2t} ne $exists->{iso_code_2t}))
        {
            use Data::Dumper;
            warn "Unexpected discrepancy:\n";
            warn "existing data: ".Dumper ($exists)."\n";
            warn "new data: ".Dumper (\%data)."\n";
            die; 
        }

        print "Updating ".$data{iso_code_3}."\n";
        $c->sql->update_row ('language', \%data, { id => $exists->{id} });
    }
    else
    {
        print "Inserting ".$data{iso_code_3}."\n";
        $c->sql->insert_row ('language', \%data);
    }

    $count++;
}

$c->sql->do ("UPDATE language SET frequency = 0 WHERE iso_code_3 IS NULL;");

$c->sql->commit;

