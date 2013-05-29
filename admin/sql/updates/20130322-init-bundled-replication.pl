#!/usr/bin/perl
use strict;
use warnings;

use DBDefs;
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

my $replication_sequence = $c->sql->select_single_value('SELECT current_replication_sequence FROM replication_control');
my $FTP_DATA_DIR = `grep FTP_DATA_DIR admin/config.sh`;
$FTP_DATA_DIR =~ s/^FTP_DATA_DIR=//;
chomp $FTP_DATA_DIR;

system("./admin/replication/BundleReplicationPackets $FTP_DATA_DIR/replication --period daily --start $replication_sequence");
system("./admin/replication/BundleReplicationPackets $FTP_DATA_DIR/replication --period weekly --start $replication_sequence");
