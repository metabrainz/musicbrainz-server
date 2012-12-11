package t::MusicBrainz::Server::Data::ReleaseLabel;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::ReleaseLabel;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+releaselabel');

my $rl_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $test->c);

my $rl = $rl_data->get_by_id(1);
is( $rl->id, 1 );
is( $rl->release_id, 1 );
is( $rl->label_id, 1 );
is( $rl->catalog_number, "ABC-123" );

ok( !$rl_data->load() );

my ($rls, $hits) = $rl_data->find_by_label(1, 100);
is( $hits, 4 );
is( scalar(@$rls), 4 );
is( $rls->[0]->release->id, 3 );
is( $rls->[0]->catalog_number, "343 960 2" );
is( $rls->[1]->release->id, 4 );
is( $rls->[1]->catalog_number, "82796 97772 2" );
is( $rls->[2]->release->id, 1 );
is( $rls->[2]->catalog_number, "ABC-123" );
is( $rls->[3]->release->id, 1 );
is( $rls->[3]->catalog_number, "ABC-123-X" );

my $sql = $test->c->sql;
$sql->begin;

$rl_data->merge_labels(1, 2);

($rls, $hits) = $rl_data->find_by_label(1, 100);
is($hits, 4);

($rls, $hits) = $rl_data->find_by_label(2, 100);
is($hits, 0);

$sql->commit;

};

test 'Merging release labels' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, <<EOSQL);

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO label_name (id, name) VALUES (1, 'Label');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1, 1, 'Comment', 2);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (2, '7a906020-72db-11de-8a39-0800200c9a66', 1, 1, 1),
           (3, '1a906020-72db-11de-8a39-0800200c9a66', 1, 1, 1),
           (4, '2a906020-72db-11de-8a39-0800200c9a66', 1, 1, 1);

INSERT INTO label (id, gid, name, sort_name)
    VALUES (1, '6b7b5f80-2d61-11e0-91fa-0800200c9a66', 1, 1);

INSERT INTO release_label (release, label, catalog_number)
    VALUES (1, 1, 'ABC'), (2, 1, 'ABC'), (2, 1, 'XYZ'),
           (3, NULL, 'MARVIN001'), (4, NULL, 'MARVIN001');

EOSQL

    subtest 'Merging when label and catalog numbers are not null' => sub {
        $test->c->model('ReleaseLabel')->merge_releases(1, 2);

        my $release = $test->c->model('Release')->get_by_id(1);
        $test->c->model('ReleaseLabel')->load($release);

        is($release->label_count => 2, 'has 2 label/catno pairs');
        ok((grep { $_->label_id == 1 && $_->catalog_number eq 'ABC' } $release->all_labels),
           'has cat no ABC for label 1');
        ok((grep { $_->label_id == 1 && $_->catalog_number eq 'XYZ' } $release->all_labels),
           'has cat no XYZ for label 1');
    };

    subtest 'Merging when label is NULL' => sub {
        $test->c->model('ReleaseLabel')->merge_releases(3, 4);

        my $release = $test->c->model('Release')->get_by_id(3);
        $test->c->model('ReleaseLabel')->load($release);

        is($release->label_count => 1, 'has 1 label/catno pairs');
        ok((grep { !defined($_->label_id) && $_->catalog_number eq 'MARVIN001' }
                $release->all_labels),
           'has MARVIN001');
    }
};

test 'Release labels are intelligently merged when one release label has a catalog and the other does not' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, <<EOSQL);
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO label_name (id, name) VALUES (1, 'Label');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1, 1, 'Comment', 2);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (2, '7a906020-72db-11de-8a39-0800200c9a66', 1, 1, 1);

INSERT INTO label (id, gid, name, sort_name)
    VALUES (1, '6b7b5f80-2d61-11e0-91fa-0800200c9a66', 1, 1);

INSERT INTO release_label (release, label, catalog_number)
    VALUES (1, 1, 'ABC'), (2, 1, NULL);

EOSQL

    $test->c->model('ReleaseLabel')->merge_releases(1, 2);

    my $release = $test->c->model('Release')->get_by_id(1);
    $test->c->model('ReleaseLabel')->load($release);

    is($release->label_count => 1, 'has 2 label/catno pairs');
    ok((grep { $_->label_id == 1 && $_->catalog_number eq 'ABC' } $release->all_labels),
           'has cat no ABC for label 1');
};

1;
