use strict;
use warnings;

use File::Spec;
use Test::Deep qw( cmp_bag );
use Test::More;
use Test::Routine;
use Test::Routine::Util;
use Try::Tiny;

use DBDefs;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

sub _create_script_context {
    MusicBrainz::Server::Context->create_script_context(
        database => 'TEST',
    );
}

sub _setup_sql {
    my $sql = shift;

    $sql->begin;
    $sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
             VALUES (505, '3aaac46d-d4cf-44a6-b9e1-f63785baa7db', 'Test Artist', 'Test Artist');

        INSERT INTO tag (id, name) VALUES (57, 'rock');

        INSERT INTO editor (id, name, email_confirm_date, password, ha1, deleted)
                    -- editor 10 has residual tags/ratings, but no other references
                    -- editor 11 also has residual tags/ratings, plus an associated edit
                    -- editor 12 is a non-deleted editor which should be untouched by the script
             VALUES (5010, 'Deleted Editor #10', now(), '{CLEARTEXT}mb', '', TRUE),
                    (5011, 'Deleted Editor #11', now(), '{CLEARTEXT}mb', '', TRUE),
                    (5012, 'Active Editor', now(), '{CLEARTEXT}mb', '', FALSE);

        INSERT INTO artist_tag_raw (artist, editor, tag)
             VALUES (505, 5010, 57),
                    (505, 5011, 57),
                    (505, 5012, 57);

        INSERT INTO artist_rating_raw (artist, editor, rating)
             VALUES (505, 5010, 10),
                    (505, 5011, 25),
                    (505, 5012, 50);

        INSERT INTO edit (id, editor, type, status, open_time, expire_time)
             VALUES (50100, 5011, 1, 1, now(), now() + interval '1 day');
        SQL
    $sql->commit;
}

END {
    my $c = _create_script_context();
    $c->sql->begin;
    $c->sql->do(<<~'SQL');
        DELETE FROM artist_rating_raw WHERE artist = 505;
        DELETE FROM artist_tag_raw WHERE artist = 505;
        DELETE FROM artist WHERE id = 505;
        DELETE FROM tag WHERE id = 57;
        DELETE FROM edit WHERE id = 50100;
        DELETE FROM editor WHERE id IN (5010, 5011, 5012);
        SQL
    $c->sql->commit;
}

test all => sub {
    my $c = _create_script_context();

    try {
        _setup_sql($c->sql);

        system(
            File::Spec->catfile(
                DBDefs->MB_SERVER_ROOT,
                'admin/cleanup/RemoveResidualUserData',
            ),
            '--database' => 'TEST',
        );
    } catch {
        die $_;
    } finally {
        $c->sql->rollback if $c->sql->is_in_transaction;
    };

    cmp_bag(
        $c->sql->select_single_column_array('SELECT editor FROM artist_tag_raw'),
        [5012],
        q(artist_tag_raw only has active editor 5012's row),
    );
    cmp_bag(
        $c->sql->select_single_column_array('SELECT editor FROM artist_rating_raw'),
        [5012],
        q(artist_rating_raw only has active editor 5012's row),
    );
    cmp_bag(
        $c->sql->select_single_column_array('SELECT id FROM editor WHERE id IN (5010, 5011, 5012)'),
        [5011, 5012],
        'unreferenced editor 5010 is hard-deleted',
    );
};

run_me;
done_testing;

1;
