package t::MusicBrainz::Server::Edit::Release::Merge;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::Merge };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MERGE );
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

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
                    { id => 2, old_position => 1, new_position => 1 }
                ]
            },
            {
                release => {
                    id => 7,
                    name => 'Release 2',
                },
                mediums => [
                    { id => 3, old_position => 1, new_position => 2 }
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
                    { id => 2, old_position => 1, new_position => 1 },
                    { id => 3, old_position => 2, new_position => 2 }
                ]
            },
            {
                release => {
                    id => 8,
                    name => 'Release 2',
                },
                mediums => [
                    { id => 4, old_position => 1, new_position => 3 }
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
    is(Set::Scalar->new(2, 3)->compare(Set::Scalar->new(@{ $edit->related_entities->{recording} })), 'equal', "Related recordings are correct");

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
                    { id => 2, old_position => 1, new_position => 1 }
                ]
            },
            {
                release => {
                    id => 7,
                    name => 'Release 2',
                },
                mediums => [
                    { id => 3, old_position => 1, new_position => 2 }
                ]
            }
        ]
    );

    is_deeply([], $edit->related_entities->{recording}, 'empty related recordings for MERGE_APPEND');
};

1;
