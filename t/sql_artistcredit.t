use strict;
use warnings;
use Test::More tests => 4;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $sql = Sql->new($c->mb->{dbh});
my $rc1 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=4");
my $rc2 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=5");

is ( $rc1, 3 );
is ( $rc2, 1 );

$sql->AutoCommit(1);
$sql->Do("DELETE FROM artist_credit WHERE id=1");

$rc1 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=4");
$rc2 = $sql->SelectSingleValue("SELECT refcount FROM artist_name WHERE id=5");

is ( $rc1, 2 );
is ( $rc2, undef );
