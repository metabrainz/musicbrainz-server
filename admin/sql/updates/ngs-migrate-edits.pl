#!/usr/bin/perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use DBDefs;
use Getopt::Long;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use TryCatch;

my $c = MusicBrainz::Server::Context->create_script_context;
my $migration = $c->model('EditMigration');

my $limit  = 1000;
my $offset = 0;

GetOptions(
    "limit=i"  => \$limit,
    "offset=i" => \$offset
);

my @upgraded;
my $sql = Sql->new($c->dbh);

printf "Upgrading edits!\n";
$sql->select('SELECT * FROM public.moderation_closed LIMIT ? OFFSET ?',
             $limit, $offset);

printf "Here we go!\n";

my $i = 0;
while (my $row = $sql->next_row_hash_ref) {
    my $historic = $migration->_new_from_row($row)
        or next;

    try {
        my $upgraded = $historic->upgrade;
        push @upgraded, $upgraded;

        printf "Upgraded #%d\n", $upgraded->id;
    }
    catch ($err) {
        printf STDERR "Could not upgrade %d\n", $historic->id;
        printf STDERR "$err\n";
    }

    printf "%d\r", $i++;
}

my $raw_sql = Sql->new($c->raw_dbh);
$raw_sql->begin;
$raw_sql->do('TRUNCATE edit CASCADE');
$raw_sql->do("TRUNCATE edit_$_ CASCADE")
    for qw( artist label release release_group work recording );

$c->model('Edit')->insert(@upgraded);

my @ids = map { $_->id } @upgraded;

my $votes = $sql->select_list_of_lists('
    SELECT id, moderator AS editor, moderation AS edit, vote, votetime, superseded
      FROM public.vote_closed
     WHERE moderation IN (' . placeholders(@ids) . ')', @ids);
$raw_sql->do(
    'INSERT INTO vote (id, editor, edit, vote, votetime, superseded)
          VALUES ' . (join ", ", (("(?, ?, ?, ?, ?, ?)") x @$votes)),
    map { @$_ } @$votes
);

$raw_sql->commit;
