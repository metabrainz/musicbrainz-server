package t::MusicBrainz::Server::Edit::Release::ReorderMediums;

use Test::Deep qw( cmp_set );
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REORDER_MEDIUMS );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

around run_test => sub {
    my ($orig, $test, @args) = @_;

    $test->c->sql->do(<<'EOSQL');

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO release_name (id, name) VALUES (1, 'Arrival');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1);

INSERT INTO tracklist (id) VALUES (1);

INSERT INTO medium (id, release, tracklist, position)
    VALUES (101, 1, 1, 1),
           (102, 1, 1, 2),
           (103, 1, 1, 3),
           (104, 1, 1, 4),
           (105, 1, 1, 5);
EOSQL

    $test->clear_edit;
    $test->clear_release;
    $test->$orig(@args);
};

with 't::Edit';
with 't::Context';

has release_to_edit => (
    is => 'ro', lazy => 1, clearer => 'clear_release',
    default => sub {
        my $test = shift;
        my $release = $test->c->model('Release')->get_by_id(1);
        $test->c->model('Medium')->load_for_releases($release);
        return $release;
    }
);

has edit => (
    is => 'ro', lazy => 1, clearer => 'clear_edit',
    default => sub {
        my $test = shift;
        return $test->c->model('Edit')->create(
            edit_type => $EDIT_RELEASE_REORDER_MEDIUMS,
            editor_id => 1,
            release   => $test->release_to_edit,
            medium_positions => $test->medium_positions
        );
    }
);

has medium_positions => (
    is => 'ro',
    default => sub {
        return [
            { medium_id => 101, old => 1, new => 1 }, # Disc 1 does not change
            { medium_id => 102, old => 2, new => 3 }, # Disc 2 is now medium #3
            { medium_id => 103, old => 3, new => 4 }, # Disc 3 is now medium #4
            { medium_id => 104, old => 4, new => 2 }, # Disc 4 is now medium #2
            { medium_id => 105, old => 5, new => 5 }, # Disc 5 does not change
        ];
    }
);

test 'Pending edits' => sub {
    my $test = shift;
    my $edit = $test->edit;

    $test->clear_release;

    is($test->release_to_edit->edits_pending, 1);
    is($test->release_to_edit->mediums->[0]->edits_pending, 1); # XXX this one doesn't need to be highlighted
    is($test->release_to_edit->mediums->[1]->edits_pending, 1);
    is($test->release_to_edit->mediums->[2]->edits_pending, 1);
    is($test->release_to_edit->mediums->[3]->edits_pending, 1);
    is($test->release_to_edit->mediums->[4]->edits_pending, 1); # XXX this one doesn't need to be highlighted
};

test 'Accept edit' => sub {
    my $test = shift;
    accept_edit($test->c, $test->edit);

    $test->clear_release;

    position_ok($test->release_to_edit, 101, 1);
    position_ok($test->release_to_edit, 102, 3);
    position_ok($test->release_to_edit, 103, 4);
    position_ok($test->release_to_edit, 104, 2);
    position_ok($test->release_to_edit, 105, 5);
};

test 'Reject edit' => sub {
    my $test = shift;

    $test->clear_release;

    position_ok($test->release_to_edit, 101, 1);
    position_ok($test->release_to_edit, 102, 2);
    position_ok($test->release_to_edit, 103, 3);
    position_ok($test->release_to_edit, 104, 4);
    position_ok($test->release_to_edit, 105, 5);
};

test 'Edit properties' => sub {
    my $test = shift;

    isa_ok($test->edit => 'MusicBrainz::Server::Edit::Release::ReorderMediums');

    cmp_set($test->edit->related_entities->{artist},
            [ 1 ],
            'is related to the release artist');

    cmp_set($test->edit->related_entities->{release},
            [ 1 ],
            'is related to the release being reordered');

    cmp_set($test->edit->related_entities->{release_group},
            [ 1 ],
            'is related to the release group of the release being reordered');
};

sub position_ok {
    my ($release, $medium_id, $position) = @_;

    my $medium = $release->mediums->[$position - 1];

    is($medium->position => $position);
    is($medium->id => $medium_id, "Disc $position should be $medium_id");
}

1;
