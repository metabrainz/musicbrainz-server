package t::MusicBrainz::Server::Edit::Release::ReorderMediums;
use strict;
use warnings;

use Test::Deep qw( cmp_set );
use Test::Routine;
use Test::More;
use Test::Fatal;

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_REORDER_MEDIUMS
    $UNTRUSTED_FLAG
);

around run_test => sub {
    my ($orig, $test, @args) = @_;

    $test->c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');

        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (1, 'Name', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
        INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
            VALUES (1, 1, 'Name', 0, '');

        INSERT INTO release_group (id, gid, name, artist_credit)
            VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Arrival', 1);

        INSERT INTO release (id, gid, name, artist_credit, release_group)
            VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1);

        INSERT INTO medium (id, release, track_count, position)
            VALUES (101, 1, 1, 1),
                   (102, 1, 1, 2),
                   (103, 1, 1, 3),
                   (104, 1, 1, 4),
                   (105, 1, 1, 5);
        SQL

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
    },
);

has edit => (
    is => 'ro', lazy => 1, clearer => 'clear_edit',
    default => sub {
        my $test = shift;
        return $test->c->model('Edit')->create(
            edit_type => $EDIT_RELEASE_REORDER_MEDIUMS,
            editor_id => 1,
            release   => $test->release_to_edit,
            medium_positions => $test->medium_positions,
        );
    },
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
    },
);

test 'Accept edit' => sub {
    my $test = shift;
    # Edit should already be accepted, since it is an autoedit
    ok(!$test->edit->is_open, 'Edit should be automatically accepted.');

    $test->clear_release;

    position_ok($test->release_to_edit, 101, 1);
    position_ok($test->release_to_edit, 102, 3);
    position_ok($test->release_to_edit, 103, 4);
    position_ok($test->release_to_edit, 104, 2);
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

test 'MBS-8580' => sub {
    my $test = shift;
    my $c = $test->c;

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_REORDER_MEDIUMS,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        medium_positions => [
            {medium_id => 101, old => 1, new => 6},
        ],
        privileges => $UNTRUSTED_FLAG,
    );

    ok($edit->is_open);

    $c->sql->do(<<~'SQL');
        INSERT INTO medium (id, release, position, format, name)
            VALUES (106, 1, 6, NULL, '');
        SQL

    isa_ok exception { $edit->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

sub position_ok {
    my ($release, $medium_id, $position) = @_;

    my $medium = $release->mediums->[$position - 1];

    is($medium->position => $position);
    is($medium->id => $medium_id, "Disc $position should be $medium_id");
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
