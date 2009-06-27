use strict;
use warnings;
use Test::More tests => 4;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $sql = Sql->new($c->mb->{dbh});
my $tc1 = $sql->SelectSingleValue("SELECT trackcount FROM tracklist WHERE id=1");
my $tc2 = $sql->SelectSingleValue("SELECT trackcount FROM tracklist WHERE id=2");

is ( $tc1, 2 );
is ( $tc2, 1 );

$sql->AutoCommit(1);
$sql->Do("DELETE FROM track WHERE tracklist=1");

$tc1 = $sql->SelectSingleValue("SELECT trackcount FROM tracklist WHERE id=1");
$tc2 = $sql->SelectSingleValue("SELECT trackcount FROM tracklist WHERE id=2");

is ( $tc1, 0 );
is ( $tc2, 1 );
