#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;
use_ok 'MusicBrainz::Server::Data::Tag';

use Sql;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+tag');

my $tag_data = MusicBrainz::Server::Data::Tag->new(
    c => $c, type => 'artist', tag_table => 'artist_tag');

my @tags = $tag_data->find_top_tags(3, 2);
is( scalar(@tags), 1 );
is( $tags[0]->tag->name, 'musical' );
is( $tags[0]->count, 1 );

@tags = $tag_data->find_top_tags(4, 2);
is( scalar(@tags), 2 );
is( $tags[0]->tag->name, 'jazz' );
is( $tags[0]->count, 9 );
is( $tags[1]->tag->name, 'musical' );
is( $tags[1]->count, 5 );

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
