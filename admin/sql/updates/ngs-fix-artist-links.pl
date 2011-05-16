#!/usr/bin/perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use Try::Tiny;

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

$c->sql->begin;
$c->raw_sql->begin;

try {
    printf STDERR "Selecting artists to update\n";
    my @non_existant = @{
        $c->sql->select_single_column_array('SELECT old_ac FROM tmp_artist_credit_repl')
    } or exit(0); # nothing to do

    my $i = 0;
    printf "Updating edit_artist\n";
    for my $artist_id (@non_existant) {
        my @edit_ids = @{ $c->raw_sql->select_single_column_array(
            'DELETE FROM edit_artist
              WHERE artist = ?
          RETURNING edit',
            $artist_id
        ) } or next;

        my @expand_to = @{
            $c->sql->select_single_column_array(
                'SELECT DISTINCT artist FROM artist_credit_name
                  WHERE artist_credit = (
                        SELECT new_ac
                          FROM tmp_artist_credit_repl
                         WHERE old_ac = ?
                        )',
                $artist_id
            )
        } or next;

        $c->raw_sql->do(
            'INSERT INTO edit_artist (edit, artist)
             VALUES ' . join(',', (('(?, ?)') x @expand_to) x @edit_ids),
            map { my $new_artist = $_; map { $_, $new_artist } @edit_ids } @expand_to
        );

        printf STDERR "\r%d/%d", $i++, scalar(@non_existant);
    }

    printf STDERR "Removing duplicates\n";
    $c->raw_sql->do('SELECT DISTINCT edit, artist INTO TEMPORARY edit_artist_distinct FROM edit_artist');
    $c->raw_sql->do('TRUNCATE edit_artist');
    $c->raw_sql->do('INSERT INTO edit_artist (edit, artist) SELECT edit, artist FROM edit_artist_distinct');

    $c->sql->commit;
    $c->raw_sql->commit;
}
catch {
    $c->sql->rollback;
    $c->raw_sql->rollback;

    die $_;
}
