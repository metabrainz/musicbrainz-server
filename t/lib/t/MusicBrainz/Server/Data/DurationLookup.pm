package t::MusicBrainz::Server::Data::DurationLookup;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::DurationLookup;
use MusicBrainz::Server::Test qw( accept_edit );
use Sql;

with 't::Context';

test 'tracklist used to fit lookup criteria but no longer does' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
    $c->sql->do ("INSERT INTO editor (id, name, password) VALUES (1, 'annotation_editor', 'password')");

    my $artist_credit = {
        names => [{ artist => { id => 1 }, name => 'Artist', join_phrase => '' }]
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
                recording_id => 1,
                length => 330160,
                artist_credit => $artist_credit,
            },
            {
                name => 'I.Y.F.F.E Guest Mix',
                position => 2,
                recording_id => 2,
                length => 262000,
                artist_credit => $artist_credit,
            }
        ]
    };

    my $toc = "1 2 44412 0 24762";

    my $durationlookup = $c->model ('DurationLookup')->lookup ($toc, 10000);
    is (scalar @$durationlookup, 0, "disc does not exist yet, no match with TOC lookup");

    my $created = $c->model ('Medium')->insert($insert_hash);
    my $medium = $c->model ('Medium')->get_by_id ($created->id);
    isa_ok($medium, 'MusicBrainz::Server::Entity::Medium');

    $durationlookup = $c->model ('DurationLookup')->lookup ($toc, 10000);
    is (scalar @$durationlookup, 1, "one match with TOC lookup");

    my $medium = $durationlookup->[0]->medium;
    $c->model ('Track')->load_for_mediums ($medium);
    $c->model ('ArtistCredit')->load ($medium->all_tracks);

    # clear length on the track and then submit an edit for the medium
    # with that track length cleared.  A disc where not all tracks have a
    # length should not have an entry in medium_index.

    $medium->tracks->[0]->clear_length ();

    my $edit = $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_MEDIUM_EDIT,
        to_edit => $medium,
        tracklist => $medium->tracks
    );

    accept_edit($c, $edit);

    my $durationlookup = $c->model ('DurationLookup')->lookup ($toc, 10000);
    is (scalar @$durationlookup, 0, "duration lookup did not find medium after it was edited");
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_durationlookup');

my $sql = $test->c->sql;

my $lookup_data = MusicBrainz::Server::Data::DurationLookup->new(c => $test->c);
does_ok($lookup_data, 'MusicBrainz::Server::Data::Role::Context');

my $result = $lookup_data->lookup("1 7 171327 150 22179 49905 69318 96240 121186 143398", 10000);
ok ( scalar(@$result) > 0, 'found results' );

if (my ($result) = grep { $_->medium_id == 1 } @$result) {
    ok ($result, 'returned medium 1');
    is ( $result->distance, 1 );
    is ( $result->medium->id, 1 );
    is ( $result->medium_id, 1 );
}

if (my ($result) = grep { $_->medium_id == 3 } @$result) {
    ok ($result, 'returned medium 3');
    is ( $result->distance, 1 );
    is ( $result->medium->id, 3 );
    is ( $result->medium_id, 3 );
}


$result = $lookup_data->lookup("1 9 189343 150 6614 32287 54041 61236 88129 92729 115276 153877", 10000);

if (my ($result) = grep { $_->medium_id == 2 } @$result) {
    ok ($result, 'returned medium 1');
    is ( $result->distance, 1 );
    is ( $result->medium->id, 2 );
    is ( $result->medium_id, 2 );
}

if (my ($result) = grep { $_->medium_id == 4 } @$result) {
    ok ($result, 'returned medium 4');
    is ( $result->distance, 1 );
    is ( $result->medium->id, 4 );
    is ( $result->medium_id, 4 );
}


};

1;
