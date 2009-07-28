#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 9;
use_ok 'MusicBrainz::Server::Data::Rating';

use Sql;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_raw_test_database($c, "
    TRUNCATE artist_rating_raw CASCADE;
    INSERT INTO artist_rating_raw (artist, editor, rating)
        VALUES (1, 1, 5), (2, 2, 5), (1, 3, 4), (1, 4, 1);
");

my $rating_data = MusicBrainz::Server::Data::Rating->new(
    c => $c, type => 'artist');
my @ratings = $rating_data->find_by_entity_id(1);
is( scalar(@ratings), 3 );
is( $ratings[0]->editor_id, 1 );
is( $ratings[0]->rating, 5 );
is( $ratings[1]->editor_id, 3 );
is( $ratings[1]->rating, 4 );
is( $ratings[2]->editor_id, 4 );
is( $ratings[2]->rating, 1 );

my $sql = Sql->new($c->dbh);
my $raw_sql = Sql->new($c->raw_dbh);

$sql->Begin;
$raw_sql->Begin;

$rating_data->delete(1);

$sql->Commit;
$raw_sql->Commit;

@ratings = $rating_data->find_by_entity_id(1);
is( scalar(@ratings), 0 );
