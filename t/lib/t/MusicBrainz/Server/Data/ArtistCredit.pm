package t::MusicBrainz::Server::Data::ArtistCredit;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::Fatal;
use Test::More;
use Test::Deep qw( cmp_deeply ignore );

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Test;

with 't::Context';

test 'merge_artists with renaming works if theres nothing to rename' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Queen', 'Queen'),
                   (2, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 'David Bowie', 'David Bowie');
        SQL

    ok !exception {
        $c->model('ArtistCredit')->merge_artists(1, [2], rename => 1)
    };
};

test 'Can have artist credits with no join phrase' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistcredit');

    my $ac_id = $c->model('ArtistCredit')->find_or_insert({
        names => [
            {
                artist => { id => 1, name => 'Ed Rush' },
                name => 'Ed Rush',
                join_phrase => undef
            },
            {
                artist => { id => 2, name => 'Optical' },
                name => 'Optical',
                join_phrase => ''
            }
        ]
    });

    cmp_ok($ac_id, '>', 0);
    my $ac = $c->model('ArtistCredit')->get_by_id($ac_id);
    is($ac->name, 'Ed RushOptical');
};

test 'Merging should combine ACs which are string-identical before merge (MBS-7482)' => sub {
    my $test = shift;
    my $c = $test->c;
    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Queen', 'Queen'),
                   (2, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 'David Bowie', 'David Bowie'),
                   (3, '427c72ff-516a-4a4c-8ce4-828811324dd7', 'Merge', 'Merge');

        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (1, 'Queen & David Bowie', 2, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7'),
                   (2, 'Queen & David Bowie', 2, 'c44109ce-57d7-3691-84c8-37926e3d41d2');

        INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
            VALUES (1, 0, 1, 'Queen', ' & '),
                   (1, 1, 2, 'David Bowie', ''),
                   (2, 0, 1, 'Queen', ' & '),
                   (2, 1, 3, 'David Bowie', '');
        SQL

    is($c->sql->select_single_value('SELECT count(*) FROM artist_credit'), 2, 'Two artist credits before merge');
    is($c->sql->select_single_value('SELECT count(*) FROM artist_credit_gid_redirect'), 0, 'No artist credit MBID redirect before merge');
    $c->model('ArtistCredit')->merge_artists(2, [ 3 ]);
    is($c->sql->select_single_value('SELECT count(*) FROM artist_credit'), 1, 'One artist credit after merge');
    is($c->sql->select_single_value('SELECT count(*) FROM artist_credit_gid_redirect'), 1, 'One artist credit MBID redirect after merge');
    is($c->sql->select_single_value('SELECT count(*) FROM artist_credit_name'), 2, 'AC after merge has two artists');
};

test 'Merging updates matching names' => sub {
    my $test = shift;
    my $c = $test->c;
    my $artist_credit_data = $c->model('ArtistCredit');

    MusicBrainz::Server::Test->prepare_test_database($c, '+artistcredit');
    my $old_redirect_gid = '949a7fd5-fe73-3e8f-922e-01ff4ca958f6';
    $c->sql->do(<<~"SQL", $old_redirect_gid);
        INSERT INTO artist_credit_gid_redirect (gid, new_id)
            VALUES (?, 1);
        SQL

    my $queen_and_david_bowie_gid = $c->sql->select_single_value(
      'SELECT gid FROM artist_credit ac WHERE name = ?', 'Queen & David Bowie');
    my $queen_and_bowie_gid = $c->sql->select_single_value(
      'SELECT gid FROM artist_credit ac WHERE name = ?', 'Queen & Bowie');

    $c->sql->begin;
    $artist_credit_data->merge_artists(3, [ 2 ], rename => 1);
    $c->sql->commit;

    # The credited name "David Bowie" is the same as the artist name, so it's
    # renamed to "Merge".
    my $artist_credit_id = $c->sql->select_single_value(
        'SELECT artist_credit FROM artist_credit_name WHERE artist = ? AND name = ?',
        3, 'Merge'
    );
    my $ac = $artist_credit_data->get_by_id($artist_credit_id);

    is( $ac->artist_count, 2, '2 artists in artist credit');
    is( $ac->name, 'Queen & Merge', 'Name is Queen & Merge');
    is( $ac->names->[0]->name, 'Queen', 'First artist credit is Queen');
    is( $ac->names->[0]->artist_id, 1 );
    is( $ac->names->[0]->artist->id, 1 );
    is( $ac->names->[0]->artist->gid, '945c079d-374e-4436-9448-da92dedef3cf' );
    is( $ac->names->[0]->artist->name, 'Queen', 'First artist is Queen');
    is( $ac->names->[0]->join_phrase, ' & ' );
    is( $ac->names->[1]->name, 'Merge', 'Second artist credit is Merge');
    is( $ac->names->[1]->artist_id, 3 );
    is( $ac->names->[1]->artist->id, 3 );
    is( $ac->names->[1]->artist->gid, '5f9913b0-7219-11de-8a39-0800200c9a66' );
    is( $ac->names->[1]->artist->name, 'Merge', 'Second artist is Merge');
    is( $ac->names->[1]->join_phrase, '' );

    my $name = $c->sql->select_single_value(
        'SELECT name FROM artist_credit ac WHERE id=?', $artist_credit_id);
    is( $name, 'Queen & Merge', 'Name is Queen & Merge' );

    my $new_redirect_new_id = $c->sql->select_single_value(
        'SELECT new_id FROM artist_credit_gid_redirect WHERE gid = ?',
        $queen_and_david_bowie_gid
    );
    is($new_redirect_new_id, $ac->id, 'Old “Queen & David Bowie” redirects to “Queen & Merge”');
    my $old_redirect_new_id = $c->sql->select_single_value(
        'SELECT new_id FROM artist_credit_gid_redirect WHERE gid = ?',
        $old_redirect_gid
    );
    is($old_redirect_new_id, $ac->id, 'Old existing redirect now points to “Queen & Merge”');

    # The credited name "Bowie" is different from the artist name, so it's
    # left alone.
    $artist_credit_id = $c->sql->select_single_value(
        'SELECT artist_credit FROM artist_credit_name WHERE artist = ? AND name = ?',
        3, 'Bowie'
    );
    $ac = $artist_credit_data->get_by_id($artist_credit_id);

    is($ac->artist_count, 2, '2 artists in artist credit');
    is($ac->name, 'Queen & Bowie', 'Name is Queen & Bowie');
    is($ac->names->[0]->name, 'Queen', 'First artist credit is Queen');
    is($ac->names->[0]->artist_id, 1);
    is($ac->names->[0]->artist->id, 1);
    is($ac->names->[0]->artist->gid, '945c079d-374e-4436-9448-da92dedef3cf');
    is($ac->names->[0]->artist->name, 'Queen', 'First artist is Queen');
    is($ac->names->[0]->join_phrase, ' & ');
    is($ac->names->[1]->name, 'Bowie', 'Second artist credit is Bowie');
    is($ac->names->[1]->artist_id, 3);
    is($ac->names->[1]->artist->id, 3);
    is($ac->names->[1]->artist->gid, '5f9913b0-7219-11de-8a39-0800200c9a66');
    is($ac->names->[1]->artist->name, 'Merge', 'Second artist is Merge');
    is($ac->names->[1]->join_phrase, '');

    $name = $c->sql->select_single_value(
        'SELECT name FROM artist_credit WHERE id = ?',
        $artist_credit_id,
    );
    is($name, 'Queen & Bowie', 'Name is Queen & Bowie');

    $new_redirect_new_id = $c->sql->select_single_value(
        'SELECT new_id FROM artist_credit_gid_redirect WHERE gid = ?',
        $queen_and_bowie_gid
    );
    is($new_redirect_new_id, $ac->id, 'Old “Queen & Bowie” redirects to the new “Queen & Bowie”');
};

test 'Merging clears the cache' => sub {
    my $test = shift;
    my $c = $test->cache_aware_c;
    my $cache = $c->cache_manager->_get_cache('external');
    my $artist_credit_data = $c->model('ArtistCredit');

    MusicBrainz::Server::Test->prepare_test_database($c, '+artistcredit');

    $artist_credit_data->get_by_ids(1);
    ok($cache->get('artist_credit:1'), 'cache contains artist credit #1');

    $c->sql->begin;
    $artist_credit_data->merge_artists(3, [ 2 ]);
    $c->sql->commit;

    ok(!$cache->get('artist_credit:1'), 'cache no longer contains artist credit #1');
};

test 'Replace artist credit' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+decompose');

    $c->model('ArtistCredit')->replace(
        { names => [
            {
                artist => { id => 5, name => 'Bob & Tom' },
                name => 'Bob & Tom',
                join_phrase => undef
            }
        ] },
        { names => [
            {
                artist => { id => 6, name => 'Ed Rush' },
                name => 'Ed Rush',
                join_phrase => undef
            },
            {
                artist => { id => 7, name => 'Optical' },
                name => 'Optical',
                join_phrase => ''
            }
        ]}
    );

    is($c->model('ArtistCredit')->get_by_id(1), undef, 'has removed artist credit 1');

    my @ents = (
        $c->model('ReleaseGroup')->get_by_id(1),
        $c->model('Release')->get_by_id(1),
        $c->model('Recording')->get_by_id(1),
        $c->model('Track')->get_by_id(1)
    );

    is((grep { $_->artist_credit_id == 1 } @ents), 0, 'nothing refers to artist credit 1');
};

test 'Replace artist credit identity' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+decompose');

    $c->model('ArtistCredit')->replace(
        { names => [
            {
                artist => { id => 5, name => 'Bob & Tom' },
                name => 'Bob & Tom',
                join_phrase => undef
            }
        ] },
        { names => [
            {
                artist => { id => 5, name => 'Bob & Tom' },
                name => 'Bob & Tom',
                join_phrase => undef
            }
        ] }
    );
    $c->model('ArtistCredit')->replace(
        { names => [
            {
                artist => { id => 5, name => 'Bob & Tom' },
                name => 'Bob & Tom',
                join_phrase => undef
            }
        ] },
        { names => [
            {
                artist => { id => 5, name => 'Bob & Tom' },
                name => 'Bob & Tom',
                join_phrase => ''
            }
        ] }
    );

    is($c->model('ArtistCredit')->get_by_id(1)->artist_count, 1,
       'artist credit still exists');
};

test 'related_entities' => sub {
    my $test = shift;
    my $c = $test->c;
    my $artist_credit_data = $c->model('ArtistCredit');

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my $ac = $artist_credit_data->get_by_id(135345);
    is_deeply( $artist_credit_data->related_entities($ac), {recording => [], release => [ 59662 ], release_group => [ 403214 ]} );
};

test 'MBS-13310: Merging artists updates empty artist_credit IDs in unreferenced_row_log' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, edits_pending)
             VALUES (10, '2de9d329-27e0-4a17-9da6-89a74948904e', 'Recording Artist', 'Recording Artist', 0),
                    (11, 'c3b87cb3-a1a0-448a-ac8b-0791d645aac4', 'Unused Artist Credit Artist', 'Unused Artist Credit Artist', 0),
                    (12, 'b4e7fb54-891f-41ce-9e5d-56e75e4753a0', 'Other Artist', 'Other Artist', 0);

        INSERT INTO artist_credit (id, gid, name, artist_count)
             VALUES (1, 'c58ec8ce-0cbd-497c-93be-5dee8aa0af69', 'Recording Artist', 1),
                    (2, '5ff2f4db-6ded-443e-a3ec-e87d77770078', 'Unused Artist Credit Artist', 1),
                    (3, '8763b517-d27c-498c-b73d-62233d35e5d1', 'Unused Artist Credit Artist & Other Artist', 2);

        INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
             VALUES (1, 0, 10, 'Recording Artist', ''),
                    (2, 0, 11, 'Unused Artist Credit Artist', ''),
                    (3, 0, 11, 'Unused Artist Credit Artist', ' & '),
                    (3, 1, 12, 'Other Artist', '');

        INSERT INTO recording (id, gid, name, artist_credit, length)
             VALUES (1, '961d5b34-747b-4a70-a5ea-c77d9382d481', 'Recording 1', 1, 123456),
                    (2, '2418c7cb-303c-41ce-9c8c-68daeeb1289d', 'Recording 2', 2, 234567),
                    (3, 'c303898c-3e7f-4f92-9366-b15e48d931c6', 'Recording 3', 3, 345678);
        SQL

    $c->model('Recording')->update(2, { artist_credit => 1 });
    $c->model('Recording')->update(3, { artist_credit => 1 });

    cmp_deeply(
        $c->sql->select_list_of_hashes('SELECT * FROM unreferenced_row_log'),
        [
          {
            inserted => ignore(),
            row_id => 2,
            table_name => 'artist_credit',
          },
          {
            inserted => ignore(),
            row_id => 3,
            table_name => 'artist_credit',
          },
        ],
        'unreferenced_row_log table was updated correctly',
    );

    $c->model('Artist')->merge(10, [11], rename => 1);

    cmp_deeply(
        $c->sql->select_list_of_hashes('SELECT * FROM artist_credit'),
        [
          {
            artist_count => 1,
            created => ignore(),
            edits_pending => 0,
            gid => 'c58ec8ce-0cbd-497c-93be-5dee8aa0af69',
            id => 1,
            name => 'Recording Artist',
            ref_count => 3,
          },
          {
            artist_count => 2,
            created => ignore(),
            edits_pending => 0,
            gid => ignore(),
            id => 6,
            name => 'Recording Artist & Other Artist',
            ref_count => 0,
          },
        ],
        'artist_credit table was updated correctly',
    );

    cmp_deeply(
        $c->sql->select_list_of_hashes('SELECT * FROM artist_credit_name'),
        [
          {
            artist_credit => 1,
            artist => 10,
            join_phrase => '',
            name => 'Recording Artist',
            position => 0,
          },
          {
            artist_credit => 6,
            artist => 10,
            join_phrase => ' & ',
            name => 'Recording Artist',
            position => 0,
          },
          {
            artist_credit => 6,
            artist => 12,
            join_phrase => '',
            name => 'Other Artist',
            position => 1,
          },
        ],
        'artist_credit_name table was updated correctly',
    );

    my %gid_redirects = map {
        $_->{gid} => $_->{new_id}
    } @{ $c->sql->select_list_of_hashes('SELECT * FROM artist_credit_gid_redirect') };

    is($gid_redirects{'5ff2f4db-6ded-443e-a3ec-e87d77770078'}, 1,
       'AC 2 redirects to AC 1');
    is($gid_redirects{'8763b517-d27c-498c-b73d-62233d35e5d1'}, 6,
       'AC 3 redirects to AC 6');

    cmp_deeply(
        $c->sql->select_list_of_hashes('SELECT * FROM unreferenced_row_log'),
        [
          {
            inserted => ignore(),
            row_id => 6,
            table_name => 'artist_credit',
          },
        ],
        'unreferenced_row_log table was updated correctly (post-merge)',
    );
};

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistcredit');

my $artist_credit_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $test->c);

my $ac = $artist_credit_data->get_by_id(1);
is ( $ac->id, 1 );
is ( $ac->artist_count, 2, '2 artists in artist credit');
is ( $ac->name, 'Queen & David Bowie', 'Name is Queen & David Bowie');
is ( $ac->names->[0]->name, 'Queen', 'First artist credit is Queen');
is ( $ac->names->[0]->artist_id, 1 );
is ( $ac->names->[0]->artist->id, 1 );
is ( $ac->names->[0]->artist->gid, '945c079d-374e-4436-9448-da92dedef3cf' );
is ( $ac->names->[0]->artist->name, 'Queen', 'First artist is Queen');
is ( $ac->names->[0]->join_phrase, ' & ' );
is ( $ac->names->[1]->name, 'David Bowie', 'Second artist credit is David Bowie');
is ( $ac->names->[1]->artist_id, 2 );
is ( $ac->names->[1]->artist->id, 2 );
is ( $ac->names->[1]->artist->gid, '5441c29d-3602-4898-b1a1-b77fa23b8e50' );
is ( $ac->names->[1]->artist->name, 'David Bowie', 'Second artist is David Bowie');
is ( $ac->names->[1]->join_phrase, '' );

$ac = $artist_credit_data->find_or_insert({
    names => [
        {
            artist => { id => 1, name => 'Queen' },
            name => 'Queen',
            join_phrase => ' & ',
        },
        {
            artist => { id => 2, name => 'David Bowie' },
            name => 'David Bowie',
            join_phrase => '',
        }
    ] });

is($ac, 1, 'Found artist credit for Queen & David Bowie');

$test->c->sql->begin;
$ac = $artist_credit_data->find_or_insert({
    names => [
        {
            artist => { id => 1, name => 'Massive Attack' },
            name => 'Massive Attack',
            join_phrase => ' and ',
        },
        {
            artist => { id => 2, name => 'Portishead' },
            name => 'Portishead',
            join_phrase => undef,
        }
    ] });

$test->c->sql->commit;
ok(defined $ac);
ok($ac > 1);

my $name = $test->c->sql->select_single_value('
    SELECT name FROM artist_credit WHERE id=?', $ac);
is($name, 'Massive Attack and Portishead', 'Artist Credit name correctly saved in artist_credit table');

$test->c->sql->begin;
$artist_credit_data->merge_artists(3, [ 2 ]);
$test->c->sql->commit;

$ac = $artist_credit_data->get_by_id(
    $test->c->sql->select_single_value(q(SELECT id FROM artist_credit WHERE name = 'Queen & David Bowie'))
);

is($ac->names->[0]->artist_id, 1);
is($ac->names->[1]->artist_id, 3);

$test->c->sql->begin;
# verify empty trailing artist credits and a trailing join phrase.
$ac = $artist_credit_data->find_or_insert({
    names => [
        { artist => { id => 1 }, name => '涼宮ハルヒ', join_phrase => '(' },
        { artist => { id => 2 }, name => '平野 綾', join_phrase => ')' },
        { artist => { id => undef }, name => '', join_phrase => '' },
        { artist => { id => undef }, name => '', join_phrase => '' },
        { artist => { id => undef }, name => '', join_phrase => '' },
    ] });
$test->c->sql->commit;
ok(defined $ac);
ok($ac > 1);

$ac = $artist_credit_data->get_by_id($ac);
is(scalar $ac->all_names, 2);

my $normalized_ac = $artist_credit_data->find_or_insert({
    names => [
        { artist => { id => 1 }, name => 'Bob', join_phrase => ' & ' },
        { artist => { id => 2 }, name => 'Tom', join_phrase => '' },
    ]
});

my $messy_ac = $artist_credit_data->find_or_insert({
    names => [
        { artist => { id => 1 }, name => 'Bob', join_phrase => '      &   ' },
        { artist => { id => 2 }, name => 'Tom', join_phrase => '' },
    ]
});

is($normalized_ac, $messy_ac);

};

1;


