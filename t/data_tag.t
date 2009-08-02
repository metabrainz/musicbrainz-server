#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 22;
use_ok 'MusicBrainz::Server::Data::Tag';

use Sql;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+tag');

my $tag_data = MusicBrainz::Server::Data::Tag->new(
    c => $c, type => 'artist', tag_table => 'artist_tag');

my @tags = $tag_data->find_top_tags(3, 2);
is( scalar(@tags), 2 );
is( $tags[0]->tag->name, 'rock' );
is( $tags[0]->count, 3 );
is( $tags[1]->tag->name, 'musical' );
is( $tags[1]->count, 1 );

@tags = $tag_data->find_top_tags(4, 2);
is( scalar(@tags), 2 );
is( $tags[0]->tag->name, 'musical' );
is( $tags[0]->count, 5 );
is( $tags[1]->tag->name, 'rock' );
is( $tags[1]->count, 3 );

my ($tags, $hits) = $tag_data->find_tags(4, 100, 0);
is( scalar(@$tags), 4 );

my $sql = Sql->new($c->dbh);
my $raw_sql = Sql->new($c->raw_dbh);

$sql->Begin;
$raw_sql->Begin;
$tag_data->delete(4);
$sql->Commit;
$raw_sql->Commit;

@tags = $tag_data->find_top_tags(4, 2);
is( scalar(@tags), 0 );

MusicBrainz::Server::Test->prepare_test_database($c, '+tag');
MusicBrainz::Server::Test->prepare_raw_test_database($c, '+tag_raw');

#     (1, 3, 1)
#     (2, 3, 2)
#     (2, 3, 3)
#     (2, 3, 4)
#     (1, 4, 1)
#     (1, 4, 2)
#     (1, 4, 3)
#     (1, 4, 4)
#     (1, 4, 5)
#     (2, 4, 1)
#     (2, 4, 2)
#     (2, 4, 3)
#     (3, 4, 4)
#     (3, 4, 5)
#     (4, 4, 2)

$sql->Begin;
$raw_sql->Begin;
$tag_data->merge(3, 4);
$sql->Commit;
$raw_sql->Commit;

#     (1, 3, 1)
#     (1, 3, 2)
#     (1, 3, 3)
#     (1, 3, 4)
#     (1, 3, 5)
#     (2, 3, 1)
#     (2, 3, 2)
#     (2, 3, 3)
#     (2, 3, 4)
#     (3, 3, 4)
#     (3, 3, 5)
#     (4, 3, 2)

@tags = $tag_data->find_top_tags(3, 10);
is( scalar(@tags), 4 );
is( $tags[0]->tag->name, 'musical' );
is( $tags[0]->count, 5 );
is( $tags[1]->tag->name, 'rock' );
is( $tags[1]->count, 4 );
is( $tags[2]->tag->name, 'jazz' );
is( $tags[2]->count, 2 );
is( $tags[3]->tag->name, 'world music' );
is( $tags[3]->count, 1 );
