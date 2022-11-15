package t::MusicBrainz::Server::Data::Medium;
use strict;
use warnings;

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
                number => 'A1',
                recording_id => 1,
                length => 330160,
                artist_credit => $artist_credit,
            },
            {
                name => 'I.Y.F.F.E Guest Mix',
                position => 2,
                number => 'B1',
                recording_id => 2,
                length => 262000,
                artist_credit => $artist_credit,
            }
        ]
    };

    my $created = $c->model('Medium')->insert($insert_hash);

    my $medium = $c->model('Medium')->get_by_id($created->{id});
    isa_ok($medium, 'MusicBrainz::Server::Entity::Medium');

    $c->model('Medium')->load_track_durations($medium);
    is($medium->length, 330160 + 262000, 'inserted medium has expected length');

    my $trackoffset0 = 150;
    my $trackoffset1 = $trackoffset0 + int(330160 * 75 / 1000);
    my $leadoutoffset = $trackoffset1 + int(262000 * 75 / 1000);

    my $toc = "1 2 $leadoutoffset $trackoffset0 $trackoffset1";

    my $fuzzy = 1;
    my ($durationlookup, $hits) = $c->model('DurationLookup')->lookup($toc, $fuzzy);
    is($hits, 1, 'one match with TOC lookup');

    $medium = $c->model('Medium')->get_by_id($durationlookup->[0]{results}[0]{medium});
    is($medium->id, $created->{id});
    is($medium->name, 'Bonus disc', 'TOC lookup found correct disc');
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');

my $medium_data = MusicBrainz::Server::Data::Medium->new(c => $test->c);

my $medium = $medium_data->get_by_id(1);
is ( $medium->id, 1 );
is ( $medium->track_count, 7 );
is ( $medium->release_id, 1 );
is ( $medium->position, 1 );
is ( $medium->name, 'A Sea of Honey' );
is ( $medium->format_id, 123465 );

$medium = $medium_data->get_by_id(2);
is ( $medium->id, 2 );
is ( $medium->track_count, 9 );
is ( $medium->release_id, 1 );
is ( $medium->position, 2 );
is ( $medium->name, 'A Sky of Honey' );
is ( $medium->format_id, 123465 );

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

test 'Merging mediums with swapped recordings (MBS-9309)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+mbs-9309');

    my ($success, $error) = $c->model('Release')->determine_recording_merges(1, 2);
    is($success, 0);
    like($error->{message}, qr/^A merge cycle exists/);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
