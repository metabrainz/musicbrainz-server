use strict;
use warnings;
use Test::More tests => 9;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $sql = Sql->new($c->mb->{dbh});
my $rc1 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=100");
my $rc2 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=101");
my $rc3 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=102");

is ( $rc1, 2 );
is ( $rc2, 1 );
is ( $rc3, 1 );

$sql->auto_commit(1);
$sql->do("UPDATE artist SET name=100 WHERE id=101");

$rc1 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=100");
$rc2 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=101");
$rc3 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=102");

is ( $rc1, 3 );
is ( $rc2, undef );
is ( $rc3, 1 );

$sql->auto_commit(1);
$sql->do("DELETE FROM artist WHERE id=101");

$rc1 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=100");
$rc2 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=101");
$rc3 = $sql->select_single_value("SELECT refcount FROM artist_name WHERE id=102");

is ( $rc1, 2 );
is ( $rc2, undef );
is ( $rc3, undef );
