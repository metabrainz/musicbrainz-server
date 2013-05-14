package t::MusicBrainz::Server::Data::Medium;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Medium;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
MusicBrainz::Server::Test->prepare_test_database($test->c,
    "INSERT INTO medium_format (id, name) VALUES (2, 'Telepathic Transmission')");

my $medium_data = MusicBrainz::Server::Data::Medium->new(c => $test->c);

my $medium = $medium_data->get_by_id(1);
is ( $medium->id, 1 );
is ( $medium->track_count, 7 );
is ( $medium->release_id, 1 );
is ( $medium->position, 1 );
is ( $medium->name, 'A Sea of Honey' );
is ( $medium->format_id, 1 );

$medium = $medium_data->get_by_id(2);
is ( $medium->id, 2 );
is ( $medium->track_count, 9 );
is ( $medium->release_id, 1 );
is ( $medium->position, 2 );
is ( $medium->name, 'A Sky of Honey' );
is ( $medium->format_id, 1 );

$test->c->model('Release')->load ($medium);

is( $medium->release->name, 'Aerial' );
is( $medium->release->artist_credit_id, 1 );

# just check that it doesn't die
ok( !$medium_data->load() );

# Test editing mediums
my $sql = $test->c->sql;
$sql->begin;

$medium_data->update(1, {
        release_id => 2,
        position => 5,
        name => 'Edited name',
        format_id => 2
    });


$medium = $medium_data->get_by_id(1);
is ( $medium->release_id, 2 );
is ( $medium->position, 5 );
is ( $medium->name, 'Edited name' );
is ( $medium->format_id, 2 );

$sql->commit;

};

test 'Reordering mediums' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');

    $c->model('Medium')->reorder(
        1 => 2, # Medium 1 is now position 2
        2 => 1, # Medium 2 is now position 1
    );

    is($c->model('Medium')->get_by_id(1)->position => 2);
    is($c->model('Medium')->get_by_id(2)->position => 1);
};

1;
