use strict;
use warnings;
use Test::More tests => 4;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $sql = Sql->new($c->mb->{dbh});
my $tc1 = $sql->select_single_value("SELECT trackcount FROM tracklist WHERE id=1");
my $tc2 = $sql->select_single_value("SELECT trackcount FROM tracklist WHERE id=2");

is ( $tc1, 2 );
is ( $tc2, 1 );

$sql->auto_commit(1);
$sql->do("DELETE FROM track WHERE tracklist=1");

$tc1 = $sql->select_single_value("SELECT trackcount FROM tracklist WHERE id=1");
$tc2 = $sql->select_single_value("SELECT trackcount FROM tracklist WHERE id=2");

is ( $tc1, 0 );
is ( $tc2, 1 );
