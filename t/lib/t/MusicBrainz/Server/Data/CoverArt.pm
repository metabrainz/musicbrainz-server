package t::MusicBrainz::Server::Data::CoverArt;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Context';

test 'Release group artwork is ordered by raw/unedited, then release date' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');

        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (1, 'Name', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
        INSERT INTO release_group (id, gid, name, artist_credit, comment)
            VALUES (1, '7b5d22d0-72d7-11de-8a39-0800200c9a66', 'Release Group', 1, 'Comment');
        INSERT INTO release (id, gid, name, release_group, artist_credit)
            VALUES (1, '7b906020-72db-11de-8a39-0800200c9a70', 'Release Group', 1, 1),
                   (2, '7c906020-72db-11de-8a39-0800200c9a71', 'Release Group', 1, 1);
        INSERT INTO release_unknown_country (release, date_year, date_month, date_day)
            VALUES (1, 2000, 10, 15), (2, 2000, 11, NULL);

        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            VALUES (1, '', '', '', '', now());
        INSERT INTO edit (id, editor, type, status, expire_time)
            VALUES (1, 1, 1, 1, now()), (2, 1, 1, 1, now());
        INSERT INTO edit_data (edit, data) VALUES (1, '{}'), (2, '{}');

        INSERT INTO cover_art_archive.cover_art (id, release, edit, ordering, mime_type)
            VALUES (9876543210, 1, 1, 1, 'image/png'), (2, 2, 2, 1, 'image/png');
        INSERT INTO cover_art_archive.cover_art_type (id, type_id) VALUES (9876543210, 1), (2, 1);
        SQL

    my $release_group = $c->model('ReleaseGroup')->get_by_id(1);
    $c->model('CoverArt')->load_for_release_groups($release_group);
    is($release_group->cover_art->id, 9876543210,
       'Cover image from earliest release is selected');

    $c->sql->do(<<~'SQL');
        INSERT INTO cover_art_archive.cover_art_type (id, type_id)
             VALUES (9876543210, 14);
        SQL

    $c->model('CoverArt')->load_for_release_groups($release_group);
    is($release_group->cover_art->id, 2,
       'Non-raw cover image is selected');

    ok($c->model('CoverArt')->is_valid_id($release_group->cover_art->id), 'CAA ID larger than INT_MAX is considered valid');
};

1;
