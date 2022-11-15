package t::MusicBrainz::Server::Data::ReleaseLabel;
use strict;
use warnings;

use Test::Deep qw( cmp_deeply );
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
is( $rl->catalog_number, 'ABC-123' );

ok( !$rl_data->load() );

my $sql = $test->c->sql;
$sql->begin;

$rl_data->merge_labels(1, 2);

$sql->commit;

};

test 'Merging release labels' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, <<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Artist', 'Artist');

        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (1, 'Artist', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
        INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
            VALUES (1, 1, 'Artist', 0, '');

        INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
            VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Release', 1, 1, 'Comment', 2);

        INSERT INTO release (id, gid, name, artist_credit, release_group)
            VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Release', 1, 1),
                   (2, '7a906020-72db-11de-8a39-0800200c9a66', 'Release', 1, 1),
                   (3, '1a906020-72db-11de-8a39-0800200c9a66', 'Release', 1, 1),
                   (4, '2a906020-72db-11de-8a39-0800200c9a66', 'Release', 1, 1);

        INSERT INTO label (id, gid, name)
            VALUES (1, '6b7b5f80-2d61-11e0-91fa-0800200c9a66', 'Label');

        INSERT INTO release_label (release, label, catalog_number)
            VALUES (1, 1, 'ABC'), (2, 1, 'ABC'), (2, 1, 'XYZ'),
                   (3, NULL, 'MARVIN001'), (4, NULL, 'MARVIN001');
        SQL

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
    };
};

test 'Release labels are intelligently merged when one release label has a catalog and the other does not' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, <<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Artist', 'Artist');
        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (1, 'Artist', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

        INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
            VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Release', 1, 1, 'Comment', 2);
        INSERT INTO release (id, gid, name, artist_credit, release_group)
            VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Release', 1, 1),
                   (2, '7a906020-72db-11de-8a39-0800200c9a66', 'Release', 1, 1);

        INSERT INTO label (id, gid, name)
            VALUES (1, '6b7b5f80-2d61-11e0-91fa-0800200c9a66', 'Label');

        INSERT INTO release_label (release, label, catalog_number)
            VALUES (1, 1, 'ABC'), (2, 1, NULL);
        SQL

    $test->c->model('ReleaseLabel')->merge_releases(1, 2);

    my $release = $test->c->model('Release')->get_by_id(1);
    $test->c->model('ReleaseLabel')->load($release);

    is($release->label_count => 1, 'has 2 label/catno pairs');
    ok((grep { $_->label_id == 1 && $_->catalog_number eq 'ABC' } $release->all_labels),
           'has cat no ABC for label 1');
};

test 'Release labels are not cached on the release' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+releaselabel');

    # Ensure the release is cached.
    $c->sql->begin;
    my $release = $c->model('Release')->get_by_id(1);
    $c->model('ReleaseLabel')->load($release);
    $c->sql->commit;

    $release = $c->cache->get('release:1');
    ok(!$release->has_labels);
};

test '`load` does not duplicate labels on cached release' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+releaselabel');

    # Ensure the release is cached.
    $c->sql->begin;
    my $release = $c->model('Release')->get_by_id(1);
    $c->model('ReleaseLabel')->load($release);
    $c->sql->commit;

    # Load release from cache.
    $release = $c->model('Release')->get_by_id(1);
    $c->model('ReleaseLabel')->load($release);

    cmp_deeply(
        [map {
            id => $_->id,
            release_id => $_->release_id,
            label_id => $_->label_id,
            catalog_number => $_->catalog_number,
        }, @{ $release->labels }],
        [
            {
                id => 1,
                release_id => 1,
                label_id => 1,
                catalog_number => 'ABC-123',
            },
            {
                id => 2,
                release_id => 1,
                label_id => 1,
                catalog_number => 'ABC-123-X',
            },
        ],
        'there are two release labels',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
