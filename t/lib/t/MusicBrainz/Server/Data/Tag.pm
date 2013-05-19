package t::MusicBrainz::Server::Data::Tag;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::EntityTag;

use Sql;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+tag');

my $tag_data = MusicBrainz::Server::Data::EntityTag->new(
    c => $test->c, type => 'artist', tag_table => 'artist_tag');

my @tags = $tag_data->find_top_tags(3, 2);
is( scalar(@tags), 2 );
is( $tags[0]->tag->name, 'rock', 'Find top tags finds rock');
is( $tags[0]->count, 3 );
is( $tags[1]->tag->name, 'musical', 'Find top tags finds musical');
is( $tags[1]->count, 1 );

@tags = $tag_data->find_top_tags(4, 2);
is( scalar(@tags), 2 );
is( $tags[0]->tag->name, 'musical', 'Find top tags finds musical');
is( $tags[0]->count, 5 );
is( $tags[1]->tag->name, 'rock', 'Find top tags finds rock');
is( $tags[1]->count, 3 );

my $count = $tag_data->find_tag_count (4);
is ($count, 4, "tag count is four");

my ($tags, $hits) = $tag_data->find_tags(4, 100, 0);
is( scalar(@$tags), 4 );

$test->c->sql->begin;
$tag_data->delete(4);
$test->c->sql->commit;

@tags = $tag_data->find_top_tags(4, 2);
is( scalar(@tags), 0 );

};

test retest => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+tag');
MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+tag_raw');

my $tag_data = MusicBrainz::Server::Data::EntityTag->new(
    c => $test->c, type => 'artist', tag_table => 'artist_tag',
    parent => $test->c->model('Artist'));

# Artists tagged with 'musical'
my ($tags, $hits) = $test->c->model('Artist')->tags->find_entities(1, 10, 0);
is($hits, 2);
is(scalar(@$tags), 2);
is($tags->[0]->count, 5, "Found 5 artists tagged with musical");
is($tags->[0]->entity->id, 4);
is($tags->[0]->entity->name, 'Artist 2', '"Artist 2" is tagged with musical');
is($tags->[1]->count, 1);
is($tags->[1]->entity->id, 3);
is($tags->[1]->entity->name, 'Artist 1', '"Artist 1" is tagged with musical');

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

$test->c->sql->begin;
$tag_data->merge(3, 4);
$test->c->sql->commit;

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

my @tags = $tag_data->find_top_tags(3, 10);
is( scalar(@tags), 4 );
is( $tags[0]->tag->name, 'musical' );
is( $tags[0]->count, 5 );
is( $tags[1]->tag->name, 'rock' );
is( $tags[1]->count, 4 );
is( $tags[2]->tag->name, 'jazz' );
is( $tags[2]->count, 2 );
is( $tags[3]->tag->name, 'world music' );
is( $tags[3]->count, 1 );


@tags = $tag_data->parse_tags('world music, jazz!@');
is( scalar(@tags), 2 );
my %tags = map { $_ => 1 } @tags;
ok( exists $tags{'world music'}, 'parse tags correctly separated "world music" ...' );
ok( exists $tags{'jazz!@'},      '... and "jazz!@"');

$tag_data->update(1, 3, 'world music, techno');

@tags = $tag_data->find_top_tags(3, 10);
is( scalar(@tags), 5 );
is( $tags[0]->tag->name, 'musical' );
is( $tags[0]->count, 4 );
is( $tags[1]->tag->name, 'rock' );
is( $tags[1]->count, 3 );
is( $tags[2]->tag->name, 'jazz' );
is( $tags[2]->count, 2 );
is( $tags[3]->tag->name, 'world music' );
is( $tags[3]->count, 2 );
is( $tags[4]->tag->name, 'techno' );
is( $tags[4]->count, 1 );

$tag_data->update(1, 3, 'world music');

@tags = $tag_data->find_top_tags(3, 10);
is( scalar(@tags), 4 );
is( $tags[3]->tag->name, 'world music' );
is( $tags[3]->count, 2 );

$tag_data->update(2, 3, 'techno');

@tags = $tag_data->find_top_tags(3, 10);
is( scalar(@tags), 5 );
is( $tags[0]->tag->name, 'musical' );
is( $tags[0]->count, 3 );
is( $tags[1]->tag->name, 'jazz' );
is( $tags[1]->count, 2 );
is( $tags[2]->tag->name, 'rock' );
is( $tags[2]->count, 2 );
is( $tags[3]->tag->name, 'techno' );
is( $tags[3]->count, 1 );
is( $tags[4]->tag->name, 'world music' );
is( $tags[4]->count, 1 );

$tags = $test->c->sql->select_single_column_array("SELECT tag FROM artist_tag_raw WHERE editor=2 AND artist=3 ORDER BY tag");
is_deeply($tags, [200]);

};

1;
