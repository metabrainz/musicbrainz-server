use strict;
use warnings;
use Test::More tests => 9;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $sql = Sql->new($c->mb->{dbh});
my $rc1 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=1");
my $rc2 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=2");
my $rc3 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=3");

is ( $rc1, 2 );
is ( $rc2, 1 );
is ( $rc3, 1 );

$sql->AutoCommit(1);
$sql->Do("UPDATE artist SET name=1 WHERE id=2");

$rc1 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=1");
$rc2 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=2");
$rc3 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=3");

is ( $rc1, 3 );
is ( $rc2, undef );
is ( $rc3, 1 );

$sql->AutoCommit(1);
$sql->Do("DELETE FROM artist WHERE id=2");

$rc1 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=1");
$rc2 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=2");
$rc3 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=3");

is ( $rc1, 2 );
is ( $rc2, undef );
is ( $rc3, undef );
