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

    my @non_existant = @{
        $c->sql->select_single_column_array('SELECT old_ac FROM tmp_artist_credit_repl')
    } or exit(0); # nothing to do

    $c->raw_sql->select(
        'DELETE FROM edit_artist
          WHERE artist IN (' . join(',', ("?") x @non_existant) . ')
      RETURNING edit, artist',
        @non_existant
    );

    while (my $expand = $c->raw_sql->next_row_hash_ref) {
        my @expand_to = @{
            $c->sql->select_single_column_array(
                'SELECT artist FROM artist_credit_name
                  WHERE artist_credit = (
                        SELECT new_ac
                          FROM tmp_artist_credit_repl
                         WHERE old_ac = ?
                        )',
                $expand->{artist}
            )
        } or next;

        $c->raw_sql->do(
            'INSERT INTO edit_artist (edit, artist)
         VALUES ' . join(',', ('(?, ?)') x @expand_to),
            map { $expand->{edit}, $_ } @expand_to
        )
    }

    $c->sql->commit;
    $c->raw_sql->commit;
}
catch {
    $c->sql->rollback;
    $c->raw_sql->rollback;
}
