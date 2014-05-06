package t::MusicBrainz::Server::Data::Medium;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Medium;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test 'Insert medium' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');

    my $artist_credit = {
        names => [{
            artist => { id => 1 },
            name => 'Artist',
            join_phrase => ''
        }]
    };

    my $insert_hash = {
        name => 'Bonus disc',
        format_id => 1,
        position => 3,
        release_id => 1,
        tracklist => [
            {
                name => 'Dirty Electro Mix',
                position => 1,
                number => "A1",
                recording_id => 1,
                length => 330160,
                artist_credit => $artist_credit,
            },
            {
                name => 'I.Y.F.F.E Guest Mix',
                position => 2,
                number => "B1",
                recording_id => 2,
                length => 262000,
                artist_credit => $artist_credit,
            }
        ]
    };

    my $created = $c->model('Medium')->insert($insert_hash);
    isa_ok($created, 'MusicBrainz::Server::Entity::Medium');

    my $medium = $c->model('Medium')->get_by_id($created->id);
    isa_ok($medium, 'MusicBrainz::Server::Entity::Medium');

    $c->model('Track')->load_for_mediums($medium);
    is ($medium->length, 330160 + 262000, "inserted medium has expected length");

    my $trackoffset0 = 150;
    my $trackoffset1 = $trackoffset0 + int(330160 * 75 / 1000);
    my $leadoutoffset = $trackoffset1 + int(262000 * 75 / 1000);

    my $toc = "1 2 $leadoutoffset $trackoffset0 $trackoffset1";

    my $fuzzy = 1;
    my $durationlookup = $c->model('DurationLookup')->lookup($toc, $fuzzy);
    is (scalar @$durationlookup, 1, "one match with TOC lookup");

    $medium = $durationlookup->[0]->medium;
    is ($medium->id, $created->id);
    is ($medium->name, 'Bonus disc', 'TOC lookup found correct disc');
};

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

$test->c->model('Release')->load($medium);

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
