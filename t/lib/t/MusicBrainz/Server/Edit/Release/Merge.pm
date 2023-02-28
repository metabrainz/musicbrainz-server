package t::MusicBrainz::Server::Edit::Release::Merge;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::Merge };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MERGE $STATUS_APPLIED $STATUS_ERROR );
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Test qw( accept_edit );

test all => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 7,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        medium_changes => [
            {
                release => {
                    id => 6,
                    name => 'Release 1',
                },
                mediums => [
                    {
                        id => 2,
                        old_position => 1,
                        new_position => 1,
                        old_name => '',
                        new_name => '',
                    },
                ]
            },
            {
                release => {
                    id => 7,
                    name => 'Release 2',
                },
                mediums => [
                    {
                        id => 3,
                        old_position => 1,
                        new_position => 2,
                        old_name => '',
                        new_name => '',
                    },
                ]
            }
        ]
    );

    ok($c->model('Release')->get_by_id(6));
    ok($c->model('Release')->get_by_id(7));

    $edit = $c->model('Edit')->get_by_id($edit->id);
    accept_edit($c, $edit);

    ok($c->model('Release')->get_by_id(6));
    ok(!$c->model('Release')->get_by_id(7));

    $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 8,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        medium_changes => [
            {
                release => {
                    id => 6,
                    name => 'Release 1',
                },
                mediums => [
                    {
                        id => 2,
                        old_position => 1,
                        new_position => 1,
                        old_name => '',
                        new_name => '',
                    },
                    {
                        id => 3,
                        old_position => 2,
                        new_position => 2,
                        old_name => '',
                        new_name => '',
                    },
                ]
            },
            {
                release => {
                    id => 8,
                    name => 'Release 2',
                },
                mediums => [
                    {
                        id => 4,
                        old_position => 1,
                        new_position => 3,
                        old_name => '',
                        new_name => '',
                    },
                ]
            }
        ]
    );

    accept_edit($c, $edit);
};

test 'Linking Merge Release edits to recordings' => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 7,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE
    );

    # Use a set because the order can be different, but the elements should be the same.
    use Set::Scalar;
    is(Set::Scalar->new(2, 3)->compare(Set::Scalar->new(@{ $edit->related_entities->{recording} })), 'equal', 'Related recordings are correct');
    my $recording_in_merge = $c->model('Recording')->get_by_id(2);
    is($recording_in_merge->edits_pending, 1, 'Recording has pending edits with MERGE_MERGE');

    $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 7,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        medium_changes => [
            {
                release => {
                    id => 6,
                    name => 'Release 1',
                },
                mediums => [
                    {
                        id => 2,
                        old_position => 1,
                        new_position => 1,
                        old_name => '',
                        new_name => '',
                    },
                ]
            },
            {
                release => {
                    id => 7,
                    name => 'Release 2',
                },
                mediums => [
                    {
                        id => 3,
                        old_position => 1,
                        new_position => 2,
                        old_name => '',
                        new_name => '',
                    },
                ]
            }
        ]
    );

    is_deeply([], $edit->related_entities->{recording}, 'empty related recordings for MERGE_APPEND');
};

test 'Old medium and tracks are removed during merge' => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity =>     { id => 6, name => 'Release 1' },
        old_entities => [ { id => 7, name => 'Release 2' } ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE
    );

    $edit->accept();

    my $release = $c->model('Release')->get_by_gid('7a906020-72db-11de-8a39-0800200c9a71');
    $c->model('Medium')->load_for_releases($release);
    $c->model('Track')->load_for_mediums($release->all_mediums);

    is($release->name, 'The Prologue (disc 1)', 'Release has expected name after merge');
    is($release->combined_track_count, 1, 'Release has 1 track');
    is($release->mediums->[0]->tracks->[0]->gid, 'd6de1f70-4a29-4cce-a35b-aa2b56265583', 'Track has expected mbid');

    my $medium = $c->model('Medium')->get_by_id(3);
    is($medium, undef, 'Old medium no longer exists');

    my $track_by_mbid = $c->model('Track')->get_by_gid('929e5fb9-cfe7-4764-b3f6-80e056f0c1da');
    isnt($track_by_mbid, undef, 'track by old MBID still fetches something');
    is($track_by_mbid->gid, 'd6de1f70-4a29-4cce-a35b-aa2b56265583', 'Track mbid was redirected');

    my $track = $c->model('Track')->get_by_id(3);
    is($track, undef, 'Old track no longer exists');
};

test 'Relationships used as documentation examples are merged (MBS-8516)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO url (id, gid, url)
            VALUES (1, '4ced912c-11a5-4d7d-b280-b5adf30d81b3', 'http://en.wikipedia.org/wiki/Release');

        INSERT INTO link (id, link_type, attribute_count, begin_date_year)
            VALUES (1, 76, 0, NULL), (2, 77, 0, NULL), (3, 77, 0, '1966');

        -- Exact duplicates where both are used as an example.
        INSERT INTO l_release_url (id, link, entity0, entity1)
            VALUES (1, 1, 6, 1), (2, 1, 7, 1);

        -- Quasi-duplicates where the relationship on the merge target has a date, and
        -- the relationship on the merge source does not; the latter is used as an example.
        -- The example should be updated to use the dated relationship on the target.
        INSERT INTO l_release_url (id, link, entity0, entity1)
            VALUES (3, 2, 7, 1), (4, 3, 6, 1);

        INSERT INTO documentation.l_release_url_example (id, published, name)
            VALUES (1, TRUE, 'E1'), (2, TRUE, 'E2'), (3, TRUE, 'E3');
        SQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => { id => 6, name => 'Release 1' },
        old_entities => [{ id => 7, name => 'Release 2' }],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
    );

    $c->model('Edit')->accept($edit);
    is($edit->status, $STATUS_APPLIED);

    my $examples = $c->sql->select_single_column_array(
        'SELECT id FROM documentation.l_release_url_example ORDER BY id'
    );
    is_deeply($examples, [1, 4]);
};

test q(Appended mediums that get removed don't prevent application of the edit (MBS-8571)) => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8571');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => { id => 1, name => 'Release 1' },
        old_entities => [{ id => 2, name => 'Release 2' }],
        medium_changes => [
            {
                mediums => [
                    {
                        id => 1,
                        new_name => '',
                        new_position => 1,
                        old_name => '',
                        old_position => 1,
                    },
                ],
                release => { id => 1, name => 'Release 1' },
            },
            {
                mediums => [
                    {
                        id => 2,
                        new_name => '',
                        new_position => 2,
                        old_name => '',
                        old_position => 1,
                    },
                    {
                        id => 3,
                        new_name => '',
                        new_position => 3,
                        old_name => '',
                        old_position => 2,
                    },
                ],
                release => { id => 2, name => 'Release 2' },
            },
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
    );

    $c->model('Medium')->delete(2);
    $c->model('Edit')->accept($edit);
    is($edit->status, $STATUS_APPLIED, 'edit is applied');

    my $release = $c->model('Release')->get_by_id(1);
    $c->model('Medium')->load_for_releases($release);
    is_deeply([map { $_->id } $release->all_mediums], [1, 3], 'final medium positions are correct');
};

test 'Non-conflicting mediums appended after a release merge is entered should not block the merge (MBS-8615)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8615');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => { id => 1, name => 'Release 1' },
        old_entities => [{ id => 2, name => 'Release 2' }],
        medium_changes => [
            {
                mediums => [{ id => 1, new_name => '', new_position => 1, old_name => '', old_position => 1 }],
                release => { id => 1, name => 'Release 1' },
            },
            {
                mediums => [{ id => 2, new_name => '', new_position => 2, old_name => '', old_position => 1 }],
                release => { id => 2, name => 'Release 2' },
            },
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
    );

    ok($edit->is_open);

    my $medium_row = $c->model('Medium')->insert({
        release_id => 1,
        position => 3,
        tracklist => [],
    });

    $c->model('Edit')->accept($edit);
    is($edit->status, $STATUS_APPLIED, 'edit is applied');

    my $release = $c->model('Release')->get_by_id(1);
    $c->model('Medium')->load_for_releases($release);
    is_deeply([map { $_->id } $release->all_mediums], [1, 2, $medium_row->{id}], 'final medium ids are correct');
    is_deeply([map { $_->position } $release->all_mediums], [1, 2, 3], 'final medium positions are correct');
};

test 'Release merges should not fail if a recording is both a merge source and merge target (MBS-8614)' => sub {
    my $test = shift;
    my $c = $test->c;

    # Ignore the fact that the edit in this test case would ideally be voted
    # down (it's merging recordings that are clearly different). The scenario
    # by itself is still valid, because a release can definitely have the same
    # recording appear multiple times, for example.

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8614');

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, email, email_confirm_date, ha1)
            VALUES (1, 'new_editor', '{CLEARTEXT}password', 'example@example.com', '2005-10-20', 'e1dd8fee8ee728b0ddc8027d3a3db478');
        SQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        old_entities => [
            {
                events => [],
                mediums => [{ format_name => 'CD', track_count => 18 }],
                name => 'Diana',
                id => 1231808,
                labels => [],
                artist_credit => {
                    names => [
                        {
                            join_phrase => '',
                            name => 'Paul Anka',
                            artist => { id => 11617, name => 'Paul Anka' },
                        },
                    ],
                },
            },
        ],
        recording_merges => [
            {
                track => 4,
                sources => [{ length => 148693, id => 14317522, name => 'Lonely Boy' }],
                medium => 1,
                destination => { name => 'Lonel boy', id => 14317504, length => 147960 },
            },
            {
                destination => { id => 14317507, name => q(It's Time To Cry), length => 143573 },
                sources => [{ length => 144173, id => 14317525, name => q(It's Time To Cry) }],
                medium => 1,
                track => 7,
            },
            {
                sources => [{ id => 14317526, name => 'When I Stop Loving You', length => 107800 }],
                medium => 1,
                destination => { length => 108000, name => 'When I Stop Loving You', id => 14317508 },
                track => 8,
            },
            {
                sources => [{ length => 148773, name => q(Don't Gamble With Love), id => 14317528 }],
                destination => { name => q(It Doesn't Matter Anymore), id => 14317510, length => 147600 },
                medium => 1,
                track => 10,
            },
            {
                track => 11,
                sources => [{ name => q(It Doesn't Matter Anymore), id => 1769019, length => 109334 }],
                medium => 1,
                destination => { length => 112333, id => 14317511, name => 'Midnight' },
            },
            {
                sources => [{ length => 114000, name => 'Midnight', id => 14317530 }],
                destination => { length => 114533, name => 'Time To Cry', id => 14317512 },
                medium => 1,
                track => 12,
            },
            {
                medium => 1,
                sources => [{ id => 1769008, name => 'Time to Cry', length => 150200 }],
                destination => { length => 150240, name => 'The Longest Day', id => 14317513 },
                track => 13,
            },
            {
                destination => { id => 1769021, name => 'My Home Town', length => 126533 },
                sources => [{ name => 'The Longest Day', id => 14317532, length => 124800 }],
                medium => 1,
                track => 14,
            },
            {
                sources => [{ length => 126533, name => 'My Home Town', id => 1769021 }],
                destination => { id => 1769020, name => 'Tonight, My Love, Tonight', length => 127400 },
                medium => 1,
                track => 15,
            },
            {
                destination => { name => 'I Love You In The Same Old Way', id => 14317516, length => 129306 },
                sources => [{ length => 127400, id => 1769020, name => 'Tonight, My Love, Tonight' }],
                medium => 1,
                track => 16,
            },
            {
                sources => [{ length => 148066, id => 1769010, name => 'I Love You in the Same Old Way' }],
                medium => 1,
                destination => { name => 'I love in the same old way', id => 14317517, length => 149293 },
                track => 17,
            },
        ],
        _edit_version => 3,
        new_entity => {
            events => [],
            mediums => [{ format_name => 'CD', track_count => 18 }],
            name => 'Diana',
            id => 1231807,
            artist_credit => {
                names => [
                    {
                        join_phrase => '',
                        name => 'Paul Anka',
                        artist => { id => 11617, name => 'Paul Anka' },
                    },
                ],
            },
            labels => [],
        },
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
    );

    ok($edit->is_open);
    $c->model('Edit')->accept($edit);

    my $release = $c->model('Release')->get_by_id(1231807);
    $c->model('Medium')->load_for_releases($release);

    my @mediums = $release->all_mediums;
    $c->model('Track')->load_for_mediums(@mediums);

    is_deeply(
        [map { $_->recording_id } map { $_->all_tracks } @mediums],
        [
            518579,
            518581,
            518584,
            14317504,
            518585,
            518587,
            14317507,
            14317508,
            518586,
            14317510,
            14317511,
            14317512,
            14317513,
            14317516,
            14317516,
            14317516,
            14317517,
            518591,
        ],
        'final recording ids are correct',
    );
};

test 'Merging release with empty medium (MBS-11614)' => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $wrong_edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 101,
            name => 'One Empty Medium',
        },
        old_entities => [
            {
                id => 111,
                name => 'No Empty Mediums'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE
    );
    ok($wrong_edit->is_open);
    $c->model('Edit')->accept($wrong_edit);
    is($wrong_edit->status, $STATUS_ERROR, 'edit is not applied, with an error');

    my $right_edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 111,
            name => 'No Empty Mediums',
        },
        old_entities => [
            {
                id => 101,
                name => 'One Empty Medium'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE
    );

    ok($right_edit->is_open);
    $c->model('Edit')->accept($right_edit);
    is($right_edit->status, $STATUS_APPLIED, 'edit is applied');

    my $release = $c->model('Release')->get_by_id(111);
    $c->model('Medium')->load_for_releases($release);

    my @mediums = $release->all_mediums;
    $c->model('Track')->load_for_mediums(@mediums);

    ok($mediums[0]->track_count == 1, 'First medium has one track');
    ok($mediums[1]->track_count == 1, 'Second medium has one track');
};

test 'Merge goes through despite duplicate annotations (MBS-12550)' => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO annotation (id, editor, text)
            VALUES (100, 1, 'Annotation'),
                   (200, 1, 'Annotation');
        INSERT INTO release_annotation (release, annotation)
            VALUES (6, 100), (7, 200);
        SQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 7,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        medium_changes => [
            {
                release => {
                    id => 6,
                    name => 'Release 1',
                },
                mediums => [
                    {
                        id => 2,
                        old_position => 1,
                        new_position => 1,
                        old_name => '',
                        new_name => '',
                    },
                ]
            },
            {
                release => {
                    id => 7,
                    name => 'Release 2',
                },
                mediums => [
                    {
                        id => 3,
                        old_position => 1,
                        new_position => 2,
                        old_name => '',
                        new_name => '',
                    },
                ]
            }
        ]
    );

    accept_edit($c, $edit);
    is($edit->status, $STATUS_APPLIED, 'The edit was applied');
    my $merged_annotation = $c->model('Release')->annotation->get_latest(6);
    is(
        $merged_annotation->text,
        'Annotation',
        'The annotation was kept and not duplicated since it was the same'
    );
};

1;
