package t::MusicBrainz::Server::Data::Release;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );
use Test::Memory::Cycle;
use Test::Magpie qw( mock when inspect verify );

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
INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name) VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase) VALUES (1, 1, 1, 0, '');

INSERT INTO release_name (id, name) VALUES (1, 'R1');
INSERT INTO release_group (id, gid, name, artist_credit) VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group, barcode)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1, 1, '796122009228'),
           (2, '5b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1, 1, '600116802422'),
           (3, '6b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1, 1, NULL);
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

    ok(
        $test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
            new_id => 6, old_ids => [ 7 ]
        ),
        'can merge 2 discs with equal track counts'
    );

    ok(
        $test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
            new_id => 7,
            old_ids => [ 6 ]
        ),
        'can merge 2 discs with equal track counts in opposite direction'
    );

    ok(
        !$test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
            new_id => 6,
            old_ids => [ 3 ]
        ),
        'cannot merge releases with different track counts'
    );

    ok(
        !$test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
            new_id => 3,
            old_ids => [ 6 ]
        ),
        'cannot merge releases with different track counts in opposite direction'
    );

    $test->c->model('Release')->merge(
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        new_id => 6,
        old_ids => [ 7 ],
        medium_positions => {
            2 => 1,
            3 => 2
        }
    );

    ok(
        $test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
            new_id => 6,
            old_ids => [ 8 ]
        ),
        'can merge with differing medium counts as long as position/track count matches'
    );

    ok(
        !$test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
            new_id => 6,
            old_ids => [ 3 ]
        ),
        'cannot merge with differing medium counts when there is a track count mismatch'
    );

    ok(
        !$test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
            new_id => 8,
            old_ids => [ 6]
        ),
        'cannot merge when old mediums are not accounted for'
    );
};

test 'can_merge for the append strategy' => sub {
    my $test = shift;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO release_name (id, name) VALUES (1, 'Release');
 INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '1a906020-72db-11de-8a39-0800200c9a66', 1, 1, 1),
           (2, '2a906020-72db-11de-8a39-0800200c9a66', 1, 1, 1),
           (3, '3a906020-72db-11de-8a39-0800200c9a66', 1, 1, 1);
INSERT INTO tracklist (id) VALUES (1);
INSERT INTO medium (id, release, position, tracklist)
    VALUES (1, 1, 1, 1),
           (2, 2, 1, 1),
           (3, 3, 1, 1);
EOSQL

    ok(
        $test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
            new_id => 1,
            old_ids => [ 3 ],
            medium_positions => {
                1 => 1,
                3 => 2
            }
        )
    );

    $test->c->model('Release')->merge(
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        new_id => 1,
        old_ids => [ 3 ],
        medium_positions => {
            1 => 1,
            3 => 2
        }
    );

    ok(
        $test->c->model('Release')->can_merge(
            merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
            new_id => 1,
            old_ids => [ 2 ],
            medium_positions => {
                1 => 1,
                2 => 2,
                3 => 3,
            }
        )
    );
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
is( $release->country_id, 1 );
is( $release->script_id, 1 );
is( $release->language_id, 1 );
is( $release->date->year, 2009 );
is( $release->date->month, 5 );
is( $release->date->day, 8 );
is( $release->barcode, "731453398122" );
is( $release->comment, "Comment" );
is( $release->edits_pending, 2 );
is( $release->quality, $QUALITY_UNKNOWN_MAPPED );

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
is( $hits, 6 );
is( scalar(@$releases), 6 );
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

my @releases = $release_data->find_by_medium(1, 100);
is( $releases[0]->id, 3 );

my $annotation = $release_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );


$release = $release_data->get_by_gid('71dc55d8-0fc6-41c1-94e0-85ff2404997d');
is ( $release->id, 1, 'get release by gid' );


my %names = $release_data->find_or_insert_names('Arrival', 'Release #2', 'Protection');
is(keys %names, 3);
is($names{'Arrival'}, 1);
is($names{'Release #2'}, 2);
ok($names{'Protection'} > 2);


my $sql = $test->c->sql;
$sql->begin;
$release = $release_data->insert({
        name => 'Protection',
        artist_credit => 1,
        release_group_id => 1,
        packaging_id => 1,
        status_id => 1,
        date => { year => 2001, month => 2, day => 15 },
        barcode => '0123456789',
        country_id => 1,
        script_id => 1,
        language_id => 1,
        comment => 'A comment',
    });

$release = $release_data->get_by_id($release->id);
ok(defined $release, 'get release by id');
is($release->name, 'Protection', 'release is called "Protection"');
is($release->artist_credit_id, 1);
is($release->release_group_id, 1);
is($release->packaging_id, 1);
is($release->status_id, 1);
ok(!$release->date->is_empty);
is($release->date->year, 2001);
is($release->date->month, 2);
is($release->date->day, 15);
is($release->country_id, 1);
is($release->script_id, 1);
is($release->language_id, 1);
is($release->comment, 'A comment');

$release_data->update($release->id, {
        name => 'Blue Lines',
        country_id => 1,
        date => { year => 2002 },
    });

$release = $release_data->get_by_id($release->id);
ok(defined $release);
is($release->name, 'Blue Lines', 'release is called "Blue Lines"');
is($release->artist_credit_id, 1);
is($release->release_group_id, 1);
is($release->packaging_id, 1);
is($release->status_id, 1);
ok(!$release->date->is_empty);
is($release->date->year, 2002);
is($release->date->month, 2);
is($release->date->day, 15);
is($release->country_id, 1);

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

1;
