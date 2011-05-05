package t::MusicBrainz::Server::Data::ArtistCredit;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::ArtistCredit;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistcredit');

my $artist_credit_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $test->c);
memory_cycle_ok($artist_credit_data);

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
is ( $ac->names->[1]->join_phrase, undef );
memory_cycle_ok($artist_credit_data);
memory_cycle_ok($ac);

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
memory_cycle_ok($artist_credit_data);
memory_cycle_ok($ac);

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
memory_cycle_ok($artist_credit_data);

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


