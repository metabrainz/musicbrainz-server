#!/usr/bin/perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use aliased 'MusicBrainz::Server::Connector';
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use Sql;
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
printf STDERR "Final clear up\n";
$dbh->do('DROP INDEX puid_idx_puid');
$dbh->do('DROP INDEX recording_puid_idx_uniq');
$dbh->do('CREATE UNIQUE INDEX recording_puid_idx_uniq ON recording_puid (recording, puid)');
$dbh->do('CREATE UNIQUE INDEX puid_idx_puid ON puid (puid)');
$dbh->do('COPY public.moderation_closed TO STDOUT WITH CSV');

my $sql = Sql->new($dbh);
my $raw_sql = Sql->new($raw_dbh);

printf STDERR "Migrating edits (may be slow to start, don't panic)\n";

my ($line, $i) = ('', 0);
while ($dbh->pg_getcopydata($line)) {
    if(my $fields = $csv->parse($line)) {
        next unless $csv->fields;
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
            $skip{ $historic->id } = 1;
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

$sql = Sql->new($c->dbh);

printf STDERR "Inserting votes\n";
$sql->select('SELECT id, moderator AS editor, moderation AS edit, vote,
                     votetime AS vote_time, superseded FROM public.vote_closed
               WHERE id NOT IN (' . placeholders(values %skip) .')',
             values %skip);

$raw_sql->begin;
while(my $row = $sql->next_row_hash_ref) {
    $raw_sql->insert_row('vote', $row);    
}
$raw_sql->commit;
$sql->finish;

printf STDERR "Inserting edit notes\n";
$sql->select('SELECT id, moderation AS edit, moderator AS editor, text, notetime AS note_time
                FROM public.moderation_note_closed
               WHERE id NOT IN (' . placeholders(values %skip) .')',
             values %skip);

$raw_sql->begin;
while(my $row = $sql->next_row_hash_ref) {
    $raw_sql->insert_row('edit_note', $row);
}
$raw_sql->commit;
$sql->finish;

printf STDERR "Final clear up\n";
$dbh->do('DROP INDEX puid_idx_puid');
$dbh->do('DROP INDEX recording_puid_idx_uniq');
