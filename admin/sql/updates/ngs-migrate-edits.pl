#!/usr/bin/perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use aliased 'MusicBrainz::Server::Connector';
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

use MusicBrainz::Server::Context;
use Text::CSV_XS;
use Try::Tiny;

my $c = MusicBrainz::Server::Context->create_script_context;

my %skip = map { $_ => 1 } (
    2951, 8052, 21556, 
    21014, 21644,
    33512, 40573, 505233,
    1001582, 1025431, 1062521, 1062536
);

my $conn = Connector->new( database => Databases->get('READWRITE') );
my $csv = Text::CSV_XS->new({ binary => 1 });

my $raw_dbh = $c->raw_dbh;
$raw_dbh->do('COPY edit FROM STDIN');

my $dbh = $conn->dbh;
$dbh->do('COPY interesting TO STDOUT WITH CSV');

my ($line, $i) = ('', 0);
while ($dbh->pg_getcopydata($line)) {
    if(my $fields = $csv->parse($line)) {
        my %row;
        @row{qw(
            id artist moderator tab col type status rowid prevvalue newvalue
            yesvotes novotes depmod automod opentime closetime expiretime language
        )} = $csv->fields;
        
        next if exists $skip{ $row{id} };

        my $historic = $c->model('EditMigration')->_new_from_row(\%row)
            or next;
            
        try {
            $raw_dbh->pg_putcopydata($historic->upgrade->for_copy . "\n");
        }
        catch {
            my $err = $_;
            printf "$line\n";
            if ($err =~ /This data is corrupt and cannot be upgraded/) {
                printf "Cannot upgrade #%d: %s", $historic->id, $err;
            }
            else {
                printf STDERR "Could not upgrade %d\n", $historic->id;
                printf STDERR "$err\n";
            }
        }
    }

    printf STDERR "%d\r", $i if $i % 1000 == 0;
    $i++;
}

$raw_dbh->pg_putcopyend;
