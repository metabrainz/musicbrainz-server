package t::MusicBrainz::Script::RemoveUnreferencedRows;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

use MusicBrainz::Script::RemoveUnreferencedRows;

with 't::Context';

=head1 DESCRIPTION

This test checks whether the RemoveUnreferencedRows script is working
as expected for artist credits, deleting only the ones that are unused
after 7 days, and that artist credits are listed as unreferenced when left
unused.

=cut


my $old_redirect_gid = '949a7fd5-fe73-3e8f-922e-01ff4ca958f6';

my $ac_query = 'SELECT count(*) FROM artist_credit';

my $redirect_query = <<~'SQL';
    SELECT count(*)
      FROM artist_credit_gid_redirect
     WHERE gid = ?
       AND new_id = 1
    SQL

my $unreferenced_query = <<~'SQL';
    SELECT count(*)
      FROM unreferenced_row_log
     WHERE table_name = 'artist_credit'
       AND row_id = 1
    SQL

test 'The RemoveUnreferencedRows script keeps newly unused ACs' => sub {
    my $test = shift;
    my $c = $test->c;

    prepare_test($test);

    is(
        $c->sql->select_single_value($ac_query),
        2,
        'There are two artist credits originally',
    );

    is(
        $c->sql->select_single_value($redirect_query, $old_redirect_gid),
        1,
        'There is an old redirect pointing to the first AC',
    );

    ok !exception {
      $c->sql->do(<<~'SQL');
          UPDATE recording
             SET artist_credit = 2
           WHERE id = 1
          SQL
    }, 'The only recording using the AC was changed to a different one';

    is(
        $c->sql->select_single_value($unreferenced_query),
        0,
        'The deletion pending table is empty since the AC is still in use',
    );

    ok !exception {
        $c->sql->do(<<~'SQL');
            UPDATE release_group
               SET artist_credit = 2
             WHERE id = 1
            SQL
    }, 'The only release group using the AC was changed to a different one';

    is(
        $c->sql->select_single_value($unreferenced_query),
        1,
        'The now unused AC row has been added to the unreferenced rows table',
    );
    is(
        $c->sql->select_single_value($ac_query),
        2,
        'There are still two artist credits after the row was marked as unreferenced',
    );

    my $script = MusicBrainz::Script::RemoveUnreferencedRows->new( c => $c );
    ok !exception {
        $script->run()
    }, 'The script to remove unreferenced rows was ran successfully';

    is(
        $c->sql->select_single_value($unreferenced_query),
        1,
        'The AC row is still in the unreferenced rows table since it was just inserted',
    );

    is(
        $c->sql->select_single_value($ac_query),
        2,
        'There are still two artist credits after running the script',
    );

    is(
        $c->sql->select_single_value($redirect_query, $old_redirect_gid),
        1,
        'There is still an old redirect pointing to the AC',
    );
};

test 'The RemoveUnreferencedRows script deletes old unused ACs' => sub {
    my $test = shift;
    my $c = $test->c;

    prepare_test($test);

    is(
        $c->sql->select_single_value($ac_query),
        2,
        'There are two artist credits originally',
    );

    is(
        $c->sql->select_single_value($redirect_query, $old_redirect_gid),
        1,
        'There is an old redirect pointing to the first AC',
    );

    ok !exception {
      $c->sql->do(<<~'SQL');
          UPDATE recording
             SET artist_credit = 2
           WHERE id = 1
          SQL
    }, 'The only recording using the AC was changed to a different one';

    ok !exception {
        $c->sql->do(<<~'SQL');
            UPDATE release_group
               SET artist_credit = 2
             WHERE id = 1
            SQL
    }, 'The only release group using the AC was changed to a different one';

    is(
        $c->sql->select_single_value($unreferenced_query),
        1,
        'The now unused AC row has been added to the unreferenced rows table',
    );

    ok !exception {
        $c->sql->do(<<~'SQL');
            UPDATE unreferenced_row_log
            SET inserted = now() - '8 day'::interval
            WHERE row_id = 1
            AND table_name = 'artist_credit'
            SQL
    }, 'The unreferenced row for the AC was marked as 8 days old';

    my $script = MusicBrainz::Script::RemoveUnreferencedRows->new( c => $c );
    ok !exception {
        $script->run()
    }, 'The script to remove unreferenced rows was ran successfully';

    is(
        $c->sql->select_single_value($ac_query),
        1,
        'There is only one artist credit left after the script ran',
    );

    is(
        $c->sql->select_single_value($unreferenced_query),
        0,
        'The AC row was removed from the unreferenced rows table',
    );

    is(
        $c->sql->select_single_value($redirect_query, $old_redirect_gid),
        0,
        'There is no longer an old redirect pointing to the AC',
    );
};

test 'The RemoveUnreferencedRows script keeps ACs that are in use again' => sub {
    my $test = shift;
    my $c = $test->c;

    prepare_test($test);

    is(
        $c->sql->select_single_value($ac_query),
        2,
        'There are two artist credits originally',
    );

    is(
        $c->sql->select_single_value($redirect_query, $old_redirect_gid),
        1,
        'There is an old redirect pointing to the first AC',
    );

    ok !exception {
      $c->sql->do(<<~'SQL');
          UPDATE recording
             SET artist_credit = 2
           WHERE id = 1
          SQL
    }, 'The only recording using the AC was changed to a different one';

    ok !exception {
        $c->sql->do(<<~'SQL');
            UPDATE release_group
               SET artist_credit = 2
             WHERE id = 1
            SQL
    }, 'The only release group using the AC was changed to a different one';

    is(
        $c->sql->select_single_value($unreferenced_query),
        1,
        'The now unused AC row has been added to the unreferenced rows table',
    );

    ok !exception {
        $c->sql->do(<<~'SQL');
            UPDATE unreferenced_row_log
            SET inserted = now() - '8 day'::interval
            WHERE row_id = 1
            AND table_name = 'artist_credit'
            SQL
    }, 'The unreferenced row for the AC was marked as 8 days old';

    ok !exception {
      $c->sql->do(<<~'SQL');
          UPDATE recording
             SET artist_credit = 1
           WHERE id = 1
          SQL
    }, 'A recording was changed to use the AC again';

    my $script = MusicBrainz::Script::RemoveUnreferencedRows->new( c => $c );
    ok !exception {
        $script->run()
    }, 'The script to remove unreferenced rows was ran successfully';

    is(
        $c->sql->select_single_value($ac_query),
        2,
        'There are still two artist credits after running the script',
    );

    is(
        $c->sql->select_single_value($unreferenced_query),
        0,
        'The AC row was removed from the unreferenced rows table',
    );

    is(
        $c->sql->select_single_value($redirect_query, $old_redirect_gid),
        1,
        'There is still an old redirect pointing to the AC',
    );
};

sub prepare_test {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+artistcredit');

    $c->sql->do(<<~"SQL", $old_redirect_gid);
        INSERT INTO artist_credit_gid_redirect (gid, new_id)
            VALUES (?, 1);
        SQL
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
