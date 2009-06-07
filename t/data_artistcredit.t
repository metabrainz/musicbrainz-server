use strict;
use warnings;
use Test::More tests => 19;
use_ok 'MusicBrainz::Server::Data::ArtistCredit';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $artist_credit_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $c);

my $ac = $artist_credit_data->get_by_id(1);
is ( $ac->id, 1 );
is ( $ac->artist_count, 2 );
is ( $ac->name, "Queen & David Bowie" );
is ( $ac->names->[0]->name, "Queen" );
is ( $ac->names->[0]->artist_id, 4 );
is ( $ac->names->[0]->artist->id, 4 );
is ( $ac->names->[0]->artist->gid, "945c079d-374e-4436-9448-da92dedef3cf" );
is ( $ac->names->[0]->artist->name, "Queen" );
is ( $ac->names->[0]->join_phrase, " & " );
is ( $ac->names->[1]->name, "David Bowie" );
is ( $ac->names->[1]->artist_id, 5 );
is ( $ac->names->[1]->artist->id, 5 );
is ( $ac->names->[1]->artist->gid, "5441c29d-3602-4898-b1a1-b77fa23b8e50" );
is ( $ac->names->[1]->artist->name, "David Bowie" );
is ( $ac->names->[1]->join_phrase, undef );

my $sql = Sql->new($c->mb->dbh);
$sql->Begin;
$ac = $artist_credit_data->find_or_insert(
    { name => 'Queen', artist => 4 }, ' & ',
    { name => 'David Bowie', artist => 5 });
is($ac, 1);

$ac = $artist_credit_data->find_or_insert(
    { name => 'Massive Attack', artist => 4 }, ' and ',
    { name => 'Portishead', artist => 2 });
ok(defined $ac);
ok($ac > 4);
$sql->Commit;
