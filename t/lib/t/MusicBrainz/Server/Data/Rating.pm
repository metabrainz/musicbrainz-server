package t::MusicBrainz::Server::Data::Rating;
use Test::Routine;
use Test::Moose;
use Test::More;

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
    INSERT INTO artist (id, gid, name, sort_name, comment) VALUES
        (1, 'c09150d1-1e1b-46ad-9873-cc76d0c44499', 1, 1, 'Test 1'),
        (2, 'd09150d1-1e1b-46ad-9873-cc76d0c44499', 1, 1, 'Test 2');

    UPDATE artist_meta SET rating=33, rating_count=3 WHERE id=1;
    UPDATE artist_meta SET rating=50, rating_count=1 WHERE id=2;

    INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor1', '{CLEARTEXT}password', '0e5b1cce99adc89b535a3c6523c5410a'), (2, 'editor2', '{CLEARTEXT}password', '9ab932d00c88daf4a3ccf3a25e00f977'), (3, 'editor3', '{CLEARTEXT}password', '8226c71cd2dd007dc924910793b8ca83'), (4, 'editor4', '{CLEARTEXT}password', 'f0ab22e1a22cb1e60fea481f812450cb');

    INSERT INTO artist_rating_raw (artist, editor, rating)
        VALUES (1, 1, 50), (2, 2, 50), (1, 3, 40), (1, 4, 10);
");

my $rating_data = MusicBrainz::Server::Data::Rating->new(
    c => $test->c, type => 'artist', parent => $test->c->model('Artist') );


my @ratings = $rating_data->find_by_entity_id(1);
is( scalar(@ratings), 3 );
is( $ratings[0]->editor_id, 1 );
is( $ratings[0]->rating, 50 );
is( $ratings[1]->editor_id, 3 );
is( $ratings[1]->rating, 40 );
is( $ratings[2]->editor_id, 4 );
is( $ratings[2]->rating, 10 );


# Check that it doesn't fail on an empty list
$rating_data->load_user_ratings(1);

my $artist = MusicBrainz::Server::Entity::Artist->new( id => 1 );
is($artist->user_rating, undef);
$rating_data->load_user_ratings(1, $artist);
is($artist->user_rating, 50);
$rating_data->load_user_ratings(3, $artist);
is($artist->user_rating, 40);

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

# Update rating on artist with only one rating
$rating_data->update(2, 2, 40);
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
$test->c->sql->commit;

$artist = MusicBrainz::Server::Entity::Artist->new( id => 1 );
$artist_data->load_meta($artist);
is($artist->rating, 33);

$artist = MusicBrainz::Server::Entity::Artist->new( id => 2 );
$artist_data->load_meta($artist);
is($artist->rating, 65);

$test->c->sql->begin;
$rating_data->merge(1, 2);
$test->c->sql->commit;

$artist = MusicBrainz::Server::Entity::Artist->new( id => 1 );
$artist_data->load_meta($artist);
is($artist->rating, 45);

$rating_data->load_user_ratings(1, $artist);
is($artist->user_rating, 60);

$rating_data->load_user_ratings(2, $artist);
is($artist->user_rating, 70);

};

test 'Test find_editor_ratings' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, "
    INSERT INTO artist_name (id, name) VALUES (1, 'Test');
    INSERT INTO artist (id, gid, name, sort_name, comment) VALUES
        (1, 'c09150d1-1e1b-46ad-9873-cc76d0c44499', 1, 1, 'Test 1'),
        (2, 'd09150d1-1e1b-46ad-9873-cc76d0c44499', 1, 1, 'Test 2');

    UPDATE artist_meta SET rating=33, rating_count=3 WHERE id=1;
    UPDATE artist_meta SET rating=50, rating_count=1 WHERE id=2;

    INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor1', '{CLEARTEXT}password', '0e5b1cce99adc89b535a3c6523c5410a'), (2, 'editor2', '{CLEARTEXT}password', '9ab932d00c88daf4a3ccf3a25e00f977');

    INSERT INTO artist_rating_raw (artist, editor, rating)
        VALUES (1, 1, 50), (2, 1, 60), (1, 2, 40);
");

    my @tests = (
        { editor_id => 1, limit => 1, offset => 0, expected_hits => 2, expected_ids => [ 2 ] },
        { editor_id => 1, limit => 1, offset => 1, expected_hits => 2, expected_ids => [ 1 ] },
        { editor_id => 1, limit => 1, offset => 2, expected_hits => 2, expected_ids => [] },
        { editor_id => 2, limit => 1, offset => 0, expected_hits => 1, expected_ids => [ 1 ] },
        { editor_id => 3, limit => 1, offset => 0, expected_hits => 0, expected_ids => [ ] },
    );

    find_editor_ratings_ok($c, %$_) for @tests;
};

use Data::Dumper::Concise qw( Dumper );

sub find_editor_ratings_ok {
    my ($c, %args) = @_;

    subtest 'find_editor_ratings for ' . Dumper(\%args) => sub {
        my ($ratings, $hits) = $c->model('Artist')->rating->find_editor_ratings(
            $args{editor_id}, 0, $args{limit}, $args{offset});

        is($hits, $args{expected_hits});
        ok(scalar(@$ratings) <= $args{limit});
        is_deeply([ map { $_->id } @$ratings ], $args{expected_ids});
    };
}

1;
