package t::MusicBrainz::Server::Data::Rating;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Rating;

use Sql;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Entity::Artist;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, "
    SET client_min_messages TO 'warning';

    TRUNCATE artist CASCADE;
    TRUNCATE artist_meta CASCADE;
    TRUNCATE artist_name CASCADE;

    INSERT INTO artist_name (id, name) VALUES (1, 'Test');
    INSERT INTO artist (id, gid, name, sort_name) VALUES
        (1, 'c09150d1-1e1b-46ad-9873-cc76d0c44499', 1, 1),
        (2, 'd09150d1-1e1b-46ad-9873-cc76d0c44499', 1, 1);

    UPDATE artist_meta SET rating=33, rating_count=3 WHERE id=1;
    UPDATE artist_meta SET rating=50, rating_count=1 WHERE id=2;

    INSERT INTO editor (id, name, password) VALUES (1, 'editor1', 'password'),
                                                   (2, 'editor2', 'password'),
                                                   (3, 'editor3', 'password'),
                                                   (4, 'editor4', 'password');

    INSERT INTO artist_rating_raw (artist, editor, rating)
        VALUES (1, 1, 50), (2, 2, 50), (1, 3, 40), (1, 4, 10);
");

my $rating_data = MusicBrainz::Server::Data::Rating->new(
    c => $test->c, type => 'artist');

memory_cycle_ok($rating_data);

my @ratings = $rating_data->find_by_entity_id(1);
is( scalar(@ratings), 3 );
is( $ratings[0]->editor_id, 1 );
is( $ratings[0]->rating, 50 );
is( $ratings[1]->editor_id, 3 );
is( $ratings[1]->rating, 40 );
is( $ratings[2]->editor_id, 4 );
is( $ratings[2]->rating, 10 );

memory_cycle_ok($rating_data);
memory_cycle_ok(\@ratings);

# Check that it doesn't fail on an empty list
$rating_data->load_user_ratings(1);
memory_cycle_ok($rating_data);

my $artist = MusicBrainz::Server::Entity::Artist->new( id => 1 );
is($artist->user_rating, undef);
$rating_data->load_user_ratings(1, $artist);
is($artist->user_rating, 50);
$rating_data->load_user_ratings(3, $artist);
is($artist->user_rating, 40);
memory_cycle_ok($rating_data);
memory_cycle_ok($artist);

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

# Update rating on artist with only one rating
$rating_data->update(2, 2, 40);
memory_cycle_ok($rating_data);
$artist = MusicBrainz::Server::Entity::Artist->new( id => 2 );
$rating_data->load_user_ratings(2, $artist);
is($artist->user_rating, 40);
$artist_data->load_meta($artist);
is($artist->rating, 40);

# Delete rating on artist with only one rating
$rating_data->update(2, 2, 0);
$artist = MusicBrainz::Server::Entity::Artist->new( id => 2 );
$rating_data->load_user_ratings(2, $artist);
is($artist->user_rating, undef);
$artist_data->load_meta($artist);
is($artist->rating, undef);

# Add rating
$rating_data->update(2, 1, 70);
$artist = MusicBrainz::Server::Entity::Artist->new( id => 1 );
$rating_data->load_user_ratings(2, $artist);
is($artist->user_rating, 70);
$artist_data->load_meta($artist);
is($artist->rating, 43);

# Delete rating on artist with multiple ratings
$rating_data->update(2, 1, 0);
$artist = MusicBrainz::Server::Entity::Artist->new( id => 1 );
$rating_data->load_user_ratings(2, $artist);
is($artist->user_rating, undef);
$artist_data->load_meta($artist);
is($artist->rating, 33);

$test->c->sql->begin;
$rating_data->delete(1);
memory_cycle_ok($rating_data);
$test->c->sql->commit;

@ratings = $rating_data->find_by_entity_id(1);
is( scalar(@ratings), 0 );

MusicBrainz::Server::Test->prepare_raw_test_database($test->c, "
    TRUNCATE artist_rating_raw CASCADE;
    INSERT INTO artist_rating_raw (artist, editor, rating)
        VALUES (1, 1, 50), (2, 1, 60), (2, 2, 70), (1, 3, 40), (1, 4, 10);
");

$test->c->sql->begin;
$rating_data->_update_aggregate_rating(1);
$rating_data->_update_aggregate_rating(2);
memory_cycle_ok($rating_data);
$test->c->sql->commit;

$artist = MusicBrainz::Server::Entity::Artist->new( id => 1 );
$artist_data->load_meta($artist);
is($artist->rating, 33);

$artist = MusicBrainz::Server::Entity::Artist->new( id => 2 );
$artist_data->load_meta($artist);
is($artist->rating, 65);

$test->c->sql->begin;
$rating_data->merge(1, 2);
memory_cycle_ok($rating_data);
$test->c->sql->commit;

$artist = MusicBrainz::Server::Entity::Artist->new( id => 1 );
$artist_data->load_meta($artist);
is($artist->rating, 45);

$rating_data->load_user_ratings(1, $artist);
is($artist->user_rating, 60);

$rating_data->load_user_ratings(2, $artist);
is($artist->user_rating, 70);

};

1;
