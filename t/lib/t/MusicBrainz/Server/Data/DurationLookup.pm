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
    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            VALUES (1, 'annotation_editor', '{CLEARTEXT}password',
                    '3a115bc4f05ea9856bd4611b75c80bca', 'editor\@example.org', '2005-02-18')
        SQL

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

    my $toc = '1 2 44412 0 24762';

    my ($durationlookup, $hits) = $c->model('DurationLookup')->lookup($toc, 10000);
    is($hits, 0, 'disc does not exist yet, no match with TOC lookup');

    my $created = $c->model('Medium')->insert($insert_hash);
    my $medium = $c->model('Medium')->get_by_id($created->{id});
    isa_ok($medium, 'MusicBrainz::Server::Entity::Medium');

    ($durationlookup, $hits) = $c->model('DurationLookup')->lookup($toc, 10000);
    is($hits, 1, 'one match with TOC lookup');

    $medium = $c->model('Medium')->get_by_id($durationlookup->[0]{results}[0]{medium});
    $c->model('Track')->load_for_mediums($medium);
    $c->model('ArtistCredit')->load($medium->all_tracks);

    # clear length on the track and then submit an edit for the medium
    # with that track length cleared.  A disc where not all tracks have a
    # length should not have an entry in medium_index.

    $medium->tracks->[0]->clear_length();

    my $edit = $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_MEDIUM_EDIT,
        to_edit => $medium,
        tracklist => $medium->tracks
    );

    accept_edit($c, $edit);

    ($durationlookup, $hits) = $c->model('DurationLookup')->lookup($toc, 10000);
    is($hits, 0, 'duration lookup did not find medium after it was edited');
};

test 'TOC lookup for disc with pregap track' => sub {
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
                name => 'Secret Hidden Track',
                position => 0,
                number => '00',
                recording_id => 3,
                length => 1122,
                artist_credit => $artist_credit,
            },
            {
                name => 'Dirty Electro Mix',
                position => 1,
                number => 'A1',
                recording_id => 1,
                length => 330160,
                artist_credit => $artist_credit,
            }
        ]
    };

    my $created = $c->model('Medium')->insert($insert_hash);

    my $medium = $c->model('Medium')->get_by_id($created->{id});
    isa_ok($medium, 'MusicBrainz::Server::Entity::Medium');

    $c->model('Medium')->load_track_durations($medium);
    is($medium->length, 1122 + 330160, 'inserted medium has expected length');

    my ($durationlookup, $hits) = $c->model('DurationLookup')->lookup('1 1 39872 15110', 1);
    is($hits, 1, 'one match with TOC lookup');

    $medium = $c->model('Medium')->get_by_id($durationlookup->[0]{results}[0]{medium});
    is($medium->id, $created->{id});
    is($medium->name, 'Bonus disc', 'TOC lookup found correct disc');
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_durationlookup');

my $lookup_data = MusicBrainz::Server::Data::DurationLookup->new(c => $test->c);
does_ok($lookup_data, 'MusicBrainz::Server::Data::Role::Context');

my ($release_results, $hits) = $lookup_data->lookup('1 7 171327 150 22179 49905 69318 96240 121186 143398', 10000);
ok ( $hits > 0, 'found results' );
my $results = $release_results->[0]{results};

if (my ($result) = grep { $_->{medium} == 1 } @$results) {
    ok($result, 'returned medium 1');
    is( $result->{distance}, 1 );
    is( $result->{medium}, 1 );
}

if (my ($result) = grep { $_->{medium} == 3 } @$results) {
    ok($result, 'returned medium 3');
    is( $result->{distance}, 1 );
    is( $result->{medium}, 3 );
}


($release_results, $hits) = $lookup_data->lookup('1 9 189343 150 6614 32287 54041 61236 88129 92729 115276 153877', 10000);
$results = $release_results->[0]{results};

if (my ($result) = grep { $_->{medium} == 2 } @$results) {
    ok($result, 'returned medium 1');
    is( $result->{distance}, 1 );
    is( $result->{medium}, 2 );
}

if (my ($result) = grep { $_->{medium} == 4 } @$results) {
    ok($result, 'returned medium 4');
    is( $result->{distance}, 1 );
    is( $result->{medium}, 4 );
}


};

1;
