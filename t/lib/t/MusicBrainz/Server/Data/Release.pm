package t::MusicBrainz::Server::Data::Release;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag cmp_deeply );
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Release;

use MusicBrainz::Server::Constants qw( $QUALITY_UNKNOWN_MAPPED );
use MusicBrainz::Server::Data::ReleaseLabel;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test 'filter_barcode_changes' => sub {
    my $test = shift;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO artist (id, gid, name, sort_name) VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Name', 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase) VALUES (1, 1, 'Name', 0, '');

INSERT INTO release_group (id, gid, name, artist_credit) VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'R1', 1);
INSERT INTO release (id, gid, name, artist_credit, release_group, barcode)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'R1', 1, 1, '796122009228'),
           (2, '5b4faa80-72d9-11de-8a39-0800200c9a66', 'R1', 1, 1, '600116802422'),
           (3, '6b4faa80-72d9-11de-8a39-0800200c9a66', 'R1', 1, 1, NULL);
INSERT INTO release_gid_redirect (gid, new_id) VALUES ('1b4faa80-72d9-11de-8a39-0800200c9a66', 1);
EOSQL

    {
        my @in = ();
        my @out = $test->c->model('Release')->filter_barcode_changes(@in);
        cmp_bag(\@out, \@in, 'filtering no changes returns no changes');
    }

    {
        my @in = (
            { release => '3b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '600116802422' },
            { release => '5b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '796122009228' },
            { release => '6b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '796122009228' },
        );
        my @out = $test->c->model('Release')->filter_barcode_changes(@in);

        cmp_bag(\@out, \@in, 'all distinct changes are retained');
    }

    {
        my @in = (
            { release => '5b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '600116802422' },
            { release => '3b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '796122009228' },
            { release => '6b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '796122009228' },
        );
        my @out = $test->c->model('Release')->filter_barcode_changes(@in);

        cmp_bag(
            \@out,
            [ { release => '6b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '796122009228' } ],
            'no-ops are filtered out'
        );
    }

    {
        my @in = (
            { release => '5b4faa80-72d9-11de-8a39-0800200c9a66', barcode => undef },
        );
        my @out = $test->c->model('Release')->filter_barcode_changes(@in);

        cmp_bag(\@out, \@in, 'can set to null');
    }

    {
        my @in = (
            { release => '5b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '' },
        );
        my @out = $test->c->model('Release')->filter_barcode_changes(@in);

        cmp_bag(\@out, \@in, 'can set to an empty string');
    }

    {
        my @in = (
            { release => '5b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '' },
            { release => '5b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '' },
        );
        my @out = $test->c->model('Release')->filter_barcode_changes(@in);

        cmp_bag(\@out, [ $in[0] ], 'changes are only shown once');
    }

    {
        my @in = (
            { release => '1b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '796122009228' },
        );
        my @out = $test->c->model('Release')->filter_barcode_changes(@in);

        cmp_bag(\@out, [ ], 'inspects over gid redirects');
    }

    {
        my @in = (
            { release => '1b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '600116802422' },
        );
        my @out = $test->c->model('Release')->filter_barcode_changes(@in);

        cmp_bag(\@out, [
            { release => '1b4faa80-72d9-11de-8a39-0800200c9a66', barcode => '600116802422' }
        ], 'inspects over gid redirects');
    }
};

test 'can_merge for the merge strategy' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

    my $can_merge;

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 6, old_ids => [ 7 ]
    });
    ok($can_merge, 'can merge 2 discs with equal track counts');

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 7,
        old_ids => [ 6 ]
    });
    ok($can_merge, 'can merge 2 discs with equal track counts in opposite direction');

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 6,
        old_ids => [ 3 ]
    });
    ok(!$can_merge, 'cannot merge releases with different track counts');

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 3,
        old_ids => [ 6 ]
    });
    ok(!$can_merge, 'cannot merge releases with different track counts in opposite direction');

    $test->c->model('Release')->merge(
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        new_id => 6,
        old_ids => [ 7 ],
        medium_positions => {
            2 => 1,
            3 => 2
        }
    );

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 6,
        old_ids => [ 8 ]
    });
    ok($can_merge, 'can merge with differing medium counts as long as position/track count matches');

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 6,
        old_ids => [ 3 ]
    });
    ok(!$can_merge, 'cannot merge with differing medium counts when there is a track count mismatch');

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 8,
        old_ids => [ 6]
    });
    ok(!$can_merge, 'cannot merge when old mediums are not accounted for');

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 110,
        old_ids => [100],
    });
    ok(!$can_merge, 'cannot merge a release with a pregap into one without a pregap');

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 100,
        old_ids => [110],
    });
    ok(!$can_merge, 'cannot merge a release without a pregap into one with a pregap');
};

test 'can_merge for the append strategy' => sub {
    my $test = shift;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Name', 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 'Name', 0, '');

 INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Release', 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '1a906020-72db-11de-8a39-0800200c9a66', 'Release', 1, 1),
           (2, '2a906020-72db-11de-8a39-0800200c9a66', 'Release', 1, 1),
           (3, '3a906020-72db-11de-8a39-0800200c9a66', 'Release', 1, 1);

INSERT INTO medium (id, release, position, track_count)
    VALUES (1, 1, 1, 1),
           (2, 2, 1, 1),
           (3, 3, 1, 1);
EOSQL

    my $can_merge;

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        new_id => 1,
        old_ids => [ 3 ],
        medium_positions => {
            1 => 1,
            3 => 2
        }
    });
    ok($can_merge);

    $test->c->model('Release')->merge(
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        new_id => 1,
        old_ids => [ 3 ],
        medium_positions => {
            1 => 1,
            3 => 2
        }
    );

    ($can_merge) = $test->c->model('Release')->can_merge({
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        new_id => 1,
        old_ids => [ 2 ],
        medium_positions => {
            1 => 1,
            2 => 2,
            3 => 3,
        }
    });
    ok($can_merge);
};

test 'preserve cover_art_presence on merge' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

    $c->model('Release')->merge(
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        new_id => 6,
        old_ids => [ 7 ],
        medium_positions => {
            2 => 1,
            3 => 2
        }
    );

    my $present_result = $c->model('Release')->get_by_id(6);
    $c->model('Release')->load_meta($present_result);
    is($present_result->cover_art_presence, 'present');

    $c->model('Release')->merge(
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 8,
        old_ids => [ 9 ]
    );

    my $darkened_result = $c->model('Release')->get_by_id(8);
    $c->model('Release')->load_meta($darkened_result);
    is($darkened_result->cover_art_presence, 'darkened');
};

test 'preserve track MBIDs on merge' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

    $c->model('Release')->merge(
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 8,
        old_ids => [ 9 ]
    );

    my $redirects = $c->sql->select_list_of_hashes('SELECT gid, new_id from track_gid_redirect');

    cmp_deeply($redirects, [{'gid'=> 'a833f5c7-dd13-40ba-bb5b-dc4e35d2bb90', 'new_id' => 4}], 'gid redirect for deleted track exists');
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

my $release_data = MusicBrainz::Server::Data::Release->new(c => $test->c);

my $release = $release_data->get_by_id(1);
is( $release->id, 1, 'get release 1 by id');
is( $release->gid, "f34c079d-374e-4436-9448-da92dedef3ce" );
is( $release->name, "Arrival", 'release is called "Arrival"');
is( $release->artist_credit_id, 1 );
is( $release->release_group_id, 1 );
is( $release->status_id, 1 );
is( $release->packaging_id, 1 );
is( $release->script_id, 3 );
is( $release->language_id, 145 );
is( $release->barcode, "731453398122" );
is( $release->comment, "Comment" );
is( $release->edits_pending, 2 );
is( $release->quality, $QUALITY_UNKNOWN_MAPPED );

$release_data->load_release_events($release);
is($release->all_events, 1, 'Has one release event');
is($release->events->[0]->country_id, 221);
is($release->events->[0]->date->year, 2009);
is($release->events->[0]->date->month, 5);
is($release->events->[0]->date->day, 8);

my $release_label_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $test->c);
$release_label_data->load($release);
ok( @{$release->labels} >= 2 );
is( $release->labels->[0]->label_id, 1 );
is( $release->labels->[0]->catalog_number, "ABC-123", 'release has catalog number ABC-123');
is( $release->labels->[1]->label_id, 1 );
is( $release->labels->[1]->catalog_number, "ABC-123-X", 'release also has catalog number ABC-123-X' );

$release = $release_data->get_by_id(2);
is( $release->quality, $QUALITY_UNKNOWN_MAPPED );

my ($releases, $hits) = $release_data->find_by_artist(1, 100, 0);
is( $hits, 8 );
is( scalar(@$releases), 8 );
ok( (grep { $_->id == 1 } @$releases), 'found release by artist');
ok( (grep { $_->id == 2 } @$releases), 'found release by artist');

($releases, $hits) = $release_data->find_by_track_artist(3, 100, 0);
is( $hits, 1 );
is( scalar(@$releases), 1 );
ok( (grep { $_->id == 11 } @$releases), 'found release 11' );
ok( (grep { $_->id == 10 } @$releases) == 0, 'did not find release 10' );

($releases, $hits) = $release_data->find_by_recording(1, 100, 0);
is( $hits, 1 );
is( scalar(@$releases), 1 );
is( $releases->[0]->id, 3, 'found release by recording' );

($releases, $hits) = $release_data->find_by_release_group(1, 100, 0);
is( $hits, 6 );
is( scalar(@$releases), 6 );
ok( (grep { $_->id == 1 } @$releases), 'found release by release group' );
ok( (grep { $_->id == 2 } @$releases), 'found release by release group' );

($releases, $hits) = $release_data->find_by_medium([1], 25, 0);
is( $releases->[0]->id, 3 );

my $annotation = $release_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );


$release = $release_data->get_by_gid('71dc55d8-0fc6-41c1-94e0-85ff2404997d');
is ( $release->id, 1, 'get release by gid' );


my $sql = $test->c->sql;
$sql->begin;
$release = $release_data->insert({
    name => 'Protection',
    artist_credit => 1,
    release_group_id => 1,
    packaging_id => 1,
    status_id => 1,
    barcode => '0123456789',
    script_id => 3,
    language_id => 145,
    comment => 'A comment',
    events => [
        MusicBrainz::Server::Entity::ReleaseEvent->new(
            country_id => 221,
            date => MusicBrainz::Server::Entity::PartialDate->new( year => 2001, month => 2, day => 15 ),
        )
    ]
});

$release = $release_data->get_by_id($release->{id});
ok(defined $release, 'get release by id');
is($release->name, 'Protection', 'release is called "Protection"');
is($release->artist_credit_id, 1);
is($release->release_group_id, 1);
is($release->packaging_id, 1);
is($release->status_id, 1);
is($release->script_id, 3);
is($release->language_id, 145);
is($release->comment, 'A comment');

$release_data->load_release_events($release);
ok(!$release->events->[0]->date->is_empty);
is($release->events->[0]->date->year, 2001);
is($release->events->[0]->date->month, 2);
is($release->events->[0]->date->day, 15);
is($release->events->[0]->country_id, 221);

$release_data->update($release->id, {
    name => 'Blue Lines',
    events => [
        MusicBrainz::Server::Entity::ReleaseEvent->new(
            date => MusicBrainz::Server::Entity::PartialDate->new( year => 2002 )
        )
    ]
});

$release = $release_data->get_by_id($release->id);
ok(defined $release);
is($release->name, 'Blue Lines', 'release is called "Blue Lines"');
is($release->artist_credit_id, 1);
is($release->release_group_id, 1);
is($release->packaging_id, 1);
is($release->status_id, 1);

$release_data->load_release_events($release);
ok(!$release->events->[0]->date->is_empty);
is($release->events->[0]->date->year, 2002);
is($release->events->[0]->date->month, undef);
is($release->events->[0]->date->day, undef);
is($release->events->[0]->country_id, undef);

$release_data->delete($release->id);

$release = $release_data->get_by_id($release->id);
ok(!defined $release);

$sql->commit;

# Both #1 and #2 are in the DB
$release = $release_data->get_by_id(1);
ok(defined $release);
$release = $release_data->get_by_id(2);
ok(defined $release);

# Merge #7 into #6 with append stategy
$sql->begin;
$release_data->merge(
    new_id => 6,
    old_ids => [ 7 ],
    medium_positions => {
        3 => 1,
        2 => 2
    }
);

$release = $release_data->get_by_id(6);
$test->c->model('Medium')->load_for_releases($release);
is($release->all_mediums, 2);
is($release->mediums->[0]->id, 3);
is($release->mediums->[0]->position, 1);
is($release->mediums->[1]->id, 2);
is($release->mediums->[1]->position, 2);

# Only #6 is now in the DB
$release = $release_data->get_by_id(6);
ok(defined $release);
$release = $release_data->get_by_id(7);
ok(!defined $release);

$sql->commit;

# Merge #9 into #8 with merge stategy
$sql->begin;
$release_data->merge(new_id => 8, old_ids => [ 9 ], merge_strategy => 2);
$release = $release_data->get_by_id(8);
$test->c->model('Medium')->load_for_releases($release);
is($release->all_mediums, 1);
is($release->mediums->[0]->id, 4);
is($release->mediums->[0]->position, 1);

# Make sure it merged the recordings
is(
    $test->c->model('Recording')->get_by_gid('64cac850-f0cc-11df-98cf-0800200c9a66')->id,
    $test->c->model('Recording')->get_by_gid('691ee030-f0cc-11df-98cf-0800200c9a66')->id
);

# Only #6 is now in the DB
$release = $release_data->get_by_id(8);
ok(defined $release);
$release = $release_data->get_by_id(9);
ok(!defined $release);

# Try deleting all releases

my $release_group;
$test->c->model('ReleaseGroup')->update(1, { edits_pending => 0 });

for my $id (1, 2, 6, 8) {
    $release_group = $test->c->model('ReleaseGroup')->get_by_id(1);
    ok(defined $release_group, 'release group with releases exists');

    $release_data->delete($id);
}

$release_group = $test->c->model('ReleaseGroup')->get_by_id(1);
ok(!defined $release_group, 'deleting last release deletes release group');

$sql->commit;

};

test 'Merge and set medium names' => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

my $sql = $test->c->sql;

$sql->begin;

my $release_data = MusicBrainz::Server::Data::Release->new(c => $test->c);

# Merge #7 into #6 with append stategy
$release_data->merge(
    new_id => 6,
    old_ids => [ 7 ],
    medium_positions => {
        3 => 1,
        2 => 2
    },
    medium_names => {
        3 => 'Foo',
        2 => 'Bar'
    }
);

my $release = $release_data->get_by_id(6);
$test->c->model('Medium')->load_for_releases($release);
is($release->all_mediums, 2);
is($release->mediums->[0]->id, 3);
is($release->mediums->[0]->position, 1);
is($release->mediums->[0]->name, 'Foo');
is($release->mediums->[1]->id, 2);
is($release->mediums->[1]->position, 2);
is($release->mediums->[1]->name, 'Bar');

# Only #6 is now in the DB
$release = $release_data->get_by_id(6);
ok(defined $release);
$release = $release_data->get_by_id(7);
ok(!defined $release);

$sql->commit;

};

test 'find_by_artist orders by release date and country' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');
    $c->sql->do(<<EOSQL);
INSERT INTO area (id, gid, name, type) VALUES
  (1, '8a754a16-0027-4a29-c6d7-2b40ea0481ed', 'Estonia', 1),
  (2, '8a754a16-0027-3a29-c6d7-2b40ea0481ed', 'France', 1);
INSERT INTO country_area (area) VALUES (1), (2);
INSERT INTO iso_3166_1 (area, code) VALUES (1, 'EE'), (2, 'FR');

INSERT INTO release_unknown_country (release, date_year, date_month, date_day)
VALUES (9, 2009, 5, 8), (8, 2008, 12, 3);

INSERT INTO release_country (release, country, date_year, date_month, date_day)
VALUES (7, 2, 2009, 5, 8), (7, 1, 2009, 5, 8);
EOSQL

    my ($releases, undef) = $c->model('Release')->find_by_artist(1, 10, 0);
    is_deeply(
        [map { $_->id } @$releases],
        [8, 7, 1, 9, 110, 100, 2, 6]
    );
};

test 'find_by_label orders by release date, catalog_number, name, country, barcode' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');
    $c->sql->do(<<EOSQL);
INSERT INTO area (id, gid, name, type) VALUES
  (1, '8a754a16-0027-4a29-c6d7-2b40ea0481ed', 'Estonia', 1),
  (2, '8a754a16-0027-3a29-c6d7-2b40ea0481ed', 'France', 1);
INSERT INTO country_area (area) VALUES (1), (2);
INSERT INTO iso_3166_1 (area, code) VALUES (1, 'EE'), (2, 'FR');

INSERT INTO release_country (release, country, date_year, date_month, date_day)
VALUES (2, 2, 2007, 5, 8), (7, 1, 2008, 5, 8), (7, 2, 2008, 5, 8);

INSERT INTO release_label (release, label, catalog_number) VALUES (2, 1, 'ABC-123'), (7, 1, 'ZZZ');
EOSQL

    my ($releases, undef) = $c->model('Release')->find_by_label(1, 10, 0);
    is_deeply(
        [map { $_->id } @$releases],
        [2, 7, 1]
    );
};

test 'find_by_cdtoc' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

    my ($releases, undef) = $c->model('Release')->find_for_cdtoc(1, 1);
    is_deeply(
      [map { $_->id } @$releases],
      [8, 9, 6, 7, 100]
    );
};

test 'load_with_medium_for_recording' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

    my ($releases, undef) = $c->model('Release')->load_with_medium_for_recording(1);
    is_deeply(
      [map { $_->id } @$releases],
      [3]
    );
};

test 'find_by_disc_id' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');
    my @releases = $c->model('Release')->find_by_disc_id(
        'tLGBAiCflG8ZI6lFcOt87vXjEcI-'
    );

    is(@releases, 2);
};

test 'find_gid_for_track' => sub {
    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c);

    my $track = $c->model('Track')->get_by_gid('3fd2523e-1ced-4f83-8b93-c7ecf6960b32');
    my $mbid = $c->model('Release')->find_gid_for_track($track->id);

    is($mbid, 'f34c079d-374e-4436-9448-da92dedef3ce');
};

test 'find_by_collection ordering' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+collection');
    MusicBrainz::Server::Test->prepare_test_database($c, <<EOSQL);
INSERT INTO medium (id, release, track_count, position) VALUES (1, 1, 0, 1), (3, 3, 0, 1);
EOSQL

    for my $order (qw( date title country label artist catno format tracks )) {
        my ($releases, undef) =
            $c->model('Release')->find_by_collection(1, 50, 0, $order);

        is(@$releases, 2);
    }
};

test 'merge release events' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+release');
    $c->sql->do(<<'EOSQL');
INSERT INTO area (id, gid, name, type) VALUES
    (  5, 'e01da61e-99a8-3c76-a27d-774c3f4982f0', 'Andorra', 1),
    (122, 'd2007481-eefe-37c0-be71-2256dfe148cb', 'Liechtenstein', 1),
    (132, '050c94f7-1413-3a34-bb90-4a94f3bb2084', 'Malta', 1),
    (182, 'd4dd44b6-fa46-30f5-b331-ce9e88d06242', 'San Marino', 1);
INSERT INTO country_area (area) VALUES (5), (122), (132), (182);

INSERT INTO release_country (release, country, date_year, date_month, date_day) VALUES
    (8, 221, 2010,  2, NULL),
    (9, 221, 2009, 12, 11),
    (8, 182, 2008,  8, NULL),
    (9, 182, NULL,  7,  6),
    (8, 132, 2012, 10,  9),
    (9, 132, 2011,  9, 10),
    (8, 122, 2005,  4, 17),
    (9,   5, 2007, NULL, NULL);

INSERT INTO release_unknown_country (release, date_year, date_month, date_day) VALUES
    (8, 2013, 11, 22),
    (9, 2014,  1,  5);
EOSQL

    $c->model('Release')->merge(
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
        new_id => 8,
        old_ids => [ 9 ]
    );

    my $release = $c->model('Release')->get_by_id(8);
    $c->model('Release')->load_release_events($release);
    is($release->all_events, 6, "has six release events");
    my @country_events = grep { defined $_->country_id } $release->all_events;
    my ($re_gb) = grep { $_->country_id == 221 } @country_events;
    ok(defined $re_gb, "has release event for the U.K.");
    my ($re_sm) = grep { $_->country_id == 182 } @country_events;
    ok(defined $re_sm, "has release event for San Marino");
    my ($re_mt) = grep { $_->country_id == 132 } @country_events;
    ok(defined $re_mt, "has release event for Malta");
    my ($re_li) = grep { $_->country_id == 122 } @country_events;
    ok(defined $re_li, "has release event for Liechtenstein");
    my ($re_ad) = grep { $_->country_id ==   5 } @country_events;
    ok(defined $re_ad, "has release event for Andorra");
    my ($re_unknown) = grep { ! defined $_->country_id } $release->all_events;
    ok(defined $re_unknown, "has release event for unknown country");

    is($re_gb->date->year, 2009, "complete date is preferred over partial date");
    is($re_gb->date->month, 12);
    is($re_gb->date->day, 11);

    is($re_sm->date->year, 2008, "partial date with year is preferred over other partial date");
    is($re_sm->date->month, 8);
    ok(! defined $re_sm->date->day);

    is($re_mt->date->year, 2012, "merge target is preferred among complete dates, for known country");
    is($re_mt->date->month, 10);
    is($re_mt->date->day, 9);

    is($re_unknown->date->year, 2013, "merge target is preferred among complete dates, for unknown country");
    is($re_unknown->date->month, 11);
    is($re_unknown->date->day, 22);

    is($re_li->date->year, 2005, "release event from the merge target is retained");
    is($re_li->date->month, 4);
    is($re_li->date->day, 17);

    is($re_ad->date->year, 2007, "release event from the other merged entity is retained");
    ok(! defined $re_ad->date->month);
    ok(! defined $re_ad->date->day);
};

test 'Merging releases with the same date should discard unknown country events' => sub {
    my $test = shift;
    my $c = $test->c;
    my $release_data = $c->model('Release');

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');
    $c->sql->do(<<EOSQL);
INSERT INTO area (id, gid, name, type) VALUES
  (1, '8a754a16-0027-4a29-c6d7-2b40ea0481ed', 'Estonia', 1);
INSERT INTO country_area (area) VALUES (1);

INSERT INTO release_unknown_country (release, date_year, date_month, date_day)
VALUES (8, 2009, 5, 8);

INSERT INTO release_country (release, country, date_year, date_month, date_day)
VALUES (9, 1, 2009, 5, 8);
EOSQL

    $release_data->merge(
        old_ids => [ 9 ],
        new_id => 8,
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE
    );
    my $release = $release_data->get_by_id(8);
    $release_data->load_release_events($release);

    is((grep { $_->country_id == 1 } $release->all_events), 1,
        'one release event in Estonia');

    is((grep { !defined($_->country_id) } $release->all_events), 0,
       'no unknown release events');
};

1;
