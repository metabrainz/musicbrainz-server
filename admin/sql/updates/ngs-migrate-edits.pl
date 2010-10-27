#!/usr/bin/perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use DBDefs;
use Getopt::Long;
use IO::All;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use TryCatch;

my $c = MusicBrainz::Server::Context->create_script_context;
my $migration = $c->model('EditMigration');

my $per_select = 1000000;
my $per_copy = 100000;
my $offset = 0;

GetOptions(
    "chunk=i"  => \$per_copy,
    "select=i" => \$per_select,
    "offset=i" => \$offset,
);

my @known_corrupt = (
    2951, 8052, 21556, 
    21014, 21644,
    33512, 40573, 505233,
    1001582, 1025431, 1062521, 1062536
);

my $sql = Sql->new($c->dbh);

printf "Upgrading edits!\n";
#my $count = $sql->select_single_value(
#    'SELECT count(id) FROM public.moderation_closed');
my $count = 10105225;

printf "Here we go!\n";

my $raw_sql = Sql->new($c->raw_dbh);
$raw_sql->begin;
$raw_sql->do('TRUNCATE edit CASCADE');
$raw_sql->do("TRUNCATE edit_$_ CASCADE")
    for qw( artist label release release_group work recording );

$sql->begin;
$sql->do('CREATE UNIQUE INDEX puid_idx_puid ON puid (puid)');
$sql->do('
    CREATE UNIQUE INDEX recording_puid_idx_uniq ON recording_puid (recording, puid);
    CREATE INDEX recording_puid_idx_puid ON recording_puid (puid);
');
$sql->commit;

my $file = io('edit-migration');
$file < '';

my $i = $offset;
my @upgraded;
while (1) {
    $sql->select('SELECT * FROM public.moderation_closed
                  WHERE id NOT IN (' . placeholders(@known_corrupt) . ')
                  ORDER BY id ASC
                  LIMIT ? OFFSET ?',
                  @known_corrupt, $per_select, $offset);

    last if $sql->row_count == 0;

    while (my $row = $sql->next_row_hash_ref) {
        my $historic = $migration->_new_from_row($row)
            or next;

        try {
            my $upgraded = $historic->upgrade;
            push @upgraded, $upgraded;
        }
        catch ($err) {
            if ($err =~ /This data is corrupt and cannot be upgraded/) {
                printf "Cannot upgrade #%d: %s", $historic->id, $err;
            }
            else {
                printf STDERR "Could not upgrade %d\n", $historic->id;
                printf STDERR "$err\n";
            }
        }

        printf "%d/%d\r", $i, $count
            if $i++ % 100 == 0;

        if (@upgraded == $per_copy) {
            printf "%s: Flushing %d edits to the database\n", time, scalar(@upgraded);
            $c->model('Edit')->insert(@upgraded, $file);
            @upgraded = ();
        }
    }

    $offset += $per_select;
}

my @migrated_ids = @{ $raw_sql->select_single_column_list(
    'SELECT id FROM edit'
) };

my $votes = $sql->select_list_of_lists('
    SELECT id, moderator AS editor, moderation AS edit, vote, votetime, superseded
      FROM public.vote_closed
     WHERE moderation IN (' . placeholders(@migrated_ids) . ')', @migrated_ids);
$raw_sql->do(
    'INSERT INTO vote (id, editor, edit, vote, votetime, superseded)
          VALUES ' . (join ", ", (("(?, ?, ?, ?, ?, ?)") x @$votes)),
    map { @$_ } @$votes
) if @$votes;

$raw_sql->commit;
