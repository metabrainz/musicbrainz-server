package t::MusicBrainz::Server::Data::ArtistCredit;
use Test::Routine;
use Test::Moose;
use Test::Fatal;
use Test::More;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Test;

with 't::Context';

test 'merge_artists with renaming works if theres nothing to rename' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'Queen');
INSERT INTO artist_name (id, name) VALUES (2, 'David Bowie');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1),
           (2, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 2, 2);
EOSQL

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

test 'Merging updates the complete name' => sub {
    my $test = shift;
    my $c = $test->c;
    my $artist_credit_data = $c->model('ArtistCredit');

    MusicBrainz::Server::Test->prepare_test_database($c, '+artistcredit');

    $c->sql->begin;
    $artist_credit_data->merge_artists(3, [ 2 ], rename => 1);
    $c->sql->commit;

    my $ac = $artist_credit_data->get_by_id(1);
    is( $ac->id, 1 );
    is( $ac->artist_count, 2, "2 artists in artist credit");
    is( $ac->name, "Queen & Merge", "Name is Queen & Merge");
    is( $ac->names->[0]->name, "Queen", "First artist credit is Queen");
    is( $ac->names->[0]->artist_id, 1 );
    is( $ac->names->[0]->artist->id, 1 );
    is( $ac->names->[0]->artist->gid, "945c079d-374e-4436-9448-da92dedef3cf" );
    is( $ac->names->[0]->artist->name, "Queen", "First artist is Queen");
    is( $ac->names->[0]->join_phrase, " & " );
    is( $ac->names->[1]->name, "Merge", "Second artist credit is Merge");
    is( $ac->names->[1]->artist_id, 3 );
    is( $ac->names->[1]->artist->id, 3 );
    is( $ac->names->[1]->artist->gid, "5f9913b0-7219-11de-8a39-0800200c9a66" );
    is( $ac->names->[1]->artist->name, "Merge", "Second artist is Merge");
    is( $ac->names->[1]->join_phrase, '' );

    my $name = $c->sql->select_single_value("
        SELECT an.name FROM artist_credit ac JOIN artist_name an ON ac.name=an.id
        WHERE ac.id=1");
    is( $name, "Queen & Merge", "Name is Queen & Merge" );
};

test 'Merging clears the cache' => sub {
    my $test = shift;
    my $c = $test->cache_aware_c;
    my $cache = $c->cache_manager->_get_cache('memory');
    my $artist_credit_data = $c->model('ArtistCredit');

    MusicBrainz::Server::Test->prepare_test_database($c, '+artistcredit');

    $artist_credit_data->get_by_ids(1);
    ok($cache->exists('ac:1'), 'cache contains artist credit #1');

    $c->sql->begin;
    $artist_credit_data->merge_artists(3, [ 2 ]);
    $c->sql->commit;

    ok(!$cache->exists('ac:1'), 'cache no longer contains artist credit #1');
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

    is($c->model('ArtistCredit')->get_by_id(1)->artist_count, 0, 'has removed artist credit 1');

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

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistcredit');

my $artist_credit_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $test->c);

my $ac = $artist_credit_data->get_by_id(1);
is ( $ac->id, 1 );
is ( $ac->artist_count, 2, "2 artists in artist credit");
is ( $ac->name, "Queen & David Bowie", "Name is Queen & David Bowie");
is ( $ac->names->[0]->name, "Queen", "First artist credit is Queen");
is ( $ac->names->[0]->artist_id, 1 );
is ( $ac->names->[0]->artist->id, 1 );
is ( $ac->names->[0]->artist->gid, "945c079d-374e-4436-9448-da92dedef3cf" );
is ( $ac->names->[0]->artist->name, "Queen", "First artist is Queen");
is ( $ac->names->[0]->join_phrase, " & " );
is ( $ac->names->[1]->name, "David Bowie", "Second artist credit is David Bowie");
is ( $ac->names->[1]->artist_id, 2 );
is ( $ac->names->[1]->artist->id, 2 );
is ( $ac->names->[1]->artist->gid, "5441c29d-3602-4898-b1a1-b77fa23b8e50" );
is ( $ac->names->[1]->artist->name, "David Bowie", "Second artist is David Bowie");
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

is($ac, 1, "Found artist credit for Queen & David Bowie");

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
    SELECT name FROM artist_name
    WHERE id=(SELECT name FROM artist_credit WHERE id=?)', $ac);
is($name, "Massive Attack and Portishead", "Artist Credit name correctly saved in artist_name table");

$test->c->sql->begin;
$artist_credit_data->merge_artists(3, [ 2 ]);
$test->c->sql->commit;

$ac = $artist_credit_data->get_by_id(1);
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

};

1;


