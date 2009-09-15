#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 21;
use_ok 'MusicBrainz::Server::Data::ArtistCredit';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+artistcredit');

my $artist_credit_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $c);

my $ac = $artist_credit_data->get_by_id(1);
is ( $ac->id, 1 );
is ( $ac->artist_count, 2 );
is ( $ac->name, "Queen & David Bowie" );
is ( $ac->names->[0]->name, "Queen" );
is ( $ac->names->[0]->artist_id, 1 );
is ( $ac->names->[0]->artist->id, 1 );
is ( $ac->names->[0]->artist->gid, "945c079d-374e-4436-9448-da92dedef3cf" );
is ( $ac->names->[0]->artist->name, "Queen" );
is ( $ac->names->[0]->join_phrase, " & " );
is ( $ac->names->[1]->name, "David Bowie" );
is ( $ac->names->[1]->artist_id, 2 );
is ( $ac->names->[1]->artist->id, 2 );
is ( $ac->names->[1]->artist->gid, "5441c29d-3602-4898-b1a1-b77fa23b8e50" );
is ( $ac->names->[1]->artist->name, "David Bowie" );
is ( $ac->names->[1]->join_phrase, undef );

my $sql = Sql->new($c->mb->dbh);
$sql->begin;
$ac = $artist_credit_data->find_or_insert(
    { name => 'Queen', artist => 1 }, ' & ',
    { name => 'David Bowie', artist => 2 });
is($ac, 1);

$ac = $artist_credit_data->find_or_insert(
    { name => 'Massive Attack', artist => 1 }, ' and ',
    { name => 'Portishead', artist => 2 });
ok(defined $ac);
ok($ac > 1);

$artist_credit_data->merge_artists(3, 2);
$ac = $artist_credit_data->get_by_id(1);
is($ac->names->[0]->artist_id, 1);
is($ac->names->[1]->artist_id, 3);

$sql->commit;
