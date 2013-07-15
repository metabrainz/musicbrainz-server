package t::MusicBrainz::Server::Data::Artwork;
use Test::Routine;
use Test::More;

with 't::Context';

test 'Release group artwork is ordered by release date' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<EOSQL);
INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO release_name (id, name) VALUES (1, 'Release Group');
INSERT INTO release_group (id, gid, name, artist_credit, comment)
    VALUES (1, '7b5d22d0-72d7-11de-8a39-0800200c9a66', 1, 1, 'Comment');
INSERT INTO release (id, gid, name, release_group, artist_credit)
    VALUES (1, '7b906020-72db-11de-8a39-0800200c9a70', 1, 1, 1),
           (2, '7c906020-72db-11de-8a39-0800200c9a71', 1, 1, 1);
INSERT INTO release_unknown_country (release, date_year, date_month, date_day)
  VALUES (1, 2000, 10, 15), (2, 2000, 11, NULL);

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (1, '', '', '', '', now());
INSERT INTO edit (id, editor, type, status, data, expire_time)
VALUES (1, 1, 1, 1, '', now()), (2, 1, 1, 1, '', now());


INSERT INTO cover_art_archive.art_type (id, name) VALUES (1, 'Front');
INSERT INTO cover_art_archive.image_type (mime_type, suffix)
VALUES ('image/png', 'png');
INSERT INTO cover_art_archive.cover_art
  (id, release, edit, ordering, mime_type)
VALUES (1, 1, 1, 1, 'image/png'), (2, 2, 2, 1, 'image/png');
INSERT INTO cover_art_archive.cover_art_type (id, type_id) VALUES (1, 1), (2, 1);
EOSQL

    my $release_group = $c->model('ReleaseGroup')->get_by_id(1);
    $c->model('Artwork')->load_for_release_groups($release_group);
    is($release_group->cover_art->id, 1);
};

1;
