package t::MusicBrainz::Server::Controller::Release::Merge;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply bag );

with 't::Mechanize', 't::Context';

test 'Guess positions and append mediums' => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+release');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

$mech->get_ok('/release/merge_queue?add-to-merge=6');
$mech->get_ok('/release/merge_queue?add-to-merge=7');

$mech->get_ok('/release/merge');
$mech->submit_form_ok({
    with_fields => {
        'merge.target' => '6',
        'merge.merge_strategy' => '1',
        'merge.edit_note' => 'Mandatory',
    },
});

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Merge');
cmp_deeply($edit->data, {
    new_entity => {
        id => 6,
        name => 'The Prologue (disc 1)',
        labels => [],
        artist_credit => {
            names => [
                {
                    artist => {
                        id => 1,
                        name => 'Name',
                    },
                    join_phrase => '',
                    name => 'Name',
                },
            ],
        },
        mediums => [{
            format_name => undef,
            track_count => 1,
        }],
        events => [],
    },
    old_entities => [{
        id => 7,
        name => 'The Prologue (disc 2)',
        labels => [],
        artist_credit => {
            names => [
                {
                    artist => {
                        id => 1,
                        name => 'Name',
                    },
                    join_phrase => '',
                    name => 'Name',
                },
            ],
        },
        mediums => [{
            format_name => undef,
            track_count => 1,
        }],
        events => [],
    }],
    merge_strategy => 1,
    _edit_version => 3,
    medium_changes => bag(
        {
            release => {
                id => 6,
                name => 'The Prologue (disc 1)',
            },
            mediums => [{
                id => 2,
                old_position => 1,
                new_position => 1,
                old_name => '',
                new_name => '',
            }],
        },
        {
            release => {
                id => 7,
                name => 'The Prologue (disc 2)',
            },
            mediums => [{
                id => 3,
                old_position => 1,
                new_position => 2,
                old_name => '',
                new_name => '',
            }],
        },
    ),
});

};

test 'Update disc titles' => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+release');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

$mech->get_ok('/release/merge_queue?add-to-merge=6');
$mech->get_ok('/release/merge_queue?add-to-merge=7');

$mech->get_ok('/release/merge');
$mech->submit_form_ok({
    with_fields => {
        'merge.target' => '6',
        'merge.merge_strategy' => '1',
        'merge.medium_positions.map.0.name' => 'Foo',
        'merge.medium_positions.map.1.name' => 'Bar',
        'merge.edit_note' => 'Empty Edit Note',
    },
});

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Merge');
cmp_deeply($edit->data, {
    new_entity => {
        id => 6,
        name => 'The Prologue (disc 1)',
        labels => [],
        artist_credit => {
            names => [
                {
                    artist => {
                        id => 1,
                        name => 'Name',
                    },
                    join_phrase => '',
                    name => 'Name',
                },
            ],
        },
        mediums => [{
            format_name => undef,
            track_count => 1,
        }],
        events => [],
    },
    old_entities => [{
        id => 7,
        name => 'The Prologue (disc 2)',
        labels => [],
        artist_credit => {
            names => [
                {
                    artist => {
                        id => 1,
                        name => 'Name',
                    },
                    join_phrase => '',
                    name => 'Name',
                },
            ],
        },
        mediums => [{
            format_name => undef,
            track_count => 1,
        }],
        events => [],
    }],
    merge_strategy => 1,
    _edit_version => 3,
    medium_changes => bag(
        {
            release => {
                id => 6,
                name => 'The Prologue (disc 1)',
            },
            mediums => [{
                id => 2,
                old_position => 1,
                new_position => 1,
                old_name => '',
                new_name => 'Foo',
            }],
        },
        {
            release => {
                id => 7,
                name => 'The Prologue (disc 2)',
            },
            mediums => [{
                id => 3,
                old_position => 1,
                new_position => 2,
                old_name => '',
                new_name => 'Bar',
            }],
        },
    ),
});

};

test 'Merging recording into one other recording twice is not ambiguous' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/release/merge_queue?add-to-merge=112');
    $mech->get_ok('/release/merge_queue?add-to-merge=113');

    $mech->get_ok('/release/merge');
    $mech->submit_form_ok({
        with_fields => {
            'merge.target' => '113',
            'merge.medium_positions.map.0.position' => '1',
            'merge.medium_positions.map.1.position' => '2',
            'merge.merge_rgs' => '0',
            'merge.merge_strategy' => '2', # Merge mediums and recordings
            'merge.edit_note' => 'This is an edit note',
        },
    });

    my $release_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    note('If the latest edit is a release merge, no RG merge was entered');
    isa_ok($release_edit, 'MusicBrainz::Server::Edit::Release::Merge');
};

test 'Merging recording into two different recordings is ambiguous' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');
    # Use different recording on medium 2 of release 113 to create ambiguity
    $c->sql->do('UPDATE track SET recording = 4 WHERE id = 95');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/release/merge_queue?add-to-merge=112');
    $mech->get_ok('/release/merge_queue?add-to-merge=113');

    $mech->get_ok('/release/merge');
    $mech->submit_form_ok({
        with_fields => {
            'merge.target' => '113',
            'merge.medium_positions.map.0.position' => '1',
            'merge.medium_positions.map.1.position' => '2',
            'merge.merge_rgs' => '0',
            'merge.merge_strategy' => '2', # Merge mediums and recordings
            'merge.edit_note' => 'This is an edit note',
        },
    });
    $mech->content_contains(
        'There are multiple valid options',
        'The ambiguous recording error is shown',
    );
    my $release_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    is($release_edit, undef, 'No edit was entered');
};

test 'Can merge release groups with releases' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/release/merge_queue?add-to-merge=6');
    $mech->get_ok('/release/merge_queue?add-to-merge=100');

    $mech->get_ok('/release/merge');
    $mech->submit_form_ok({
        with_fields => {
            'merge.target' => '6',
            'merge.medium_positions.map.0.position' => '1',
            'merge.medium_positions.map.1.position' => '2',
            'merge.merge_rgs' => '1',
            'merge.merge_strategy' => '1',
            'merge.edit_note' => 'This is an edit note',
        },
    });

    my $rg_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($rg_edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');

    cmp_deeply($rg_edit->data, {
        new_entity => {
            id => 1,
            name => 'Arrival',
        },
        old_entities => [{
            id => 100,
            name => 'Pregap?',
        }],
    });

    my $release_edit = $test->c->model('Edit')->get_by_id($rg_edit->id - 1);
    isa_ok($release_edit, 'MusicBrainz::Server::Edit::Release::Merge');
};

test 'Cannot merge RGs if all releases are in the same RG' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/release/merge_queue?add-to-merge=6');
    $mech->get_ok('/release/merge_queue?add-to-merge=7');

    $mech->get_ok('/release/merge');
    $mech->submit_form_ok({
        with_fields => {
            'merge.target' => '6',
            'merge.merge_rgs' => '1',
            'merge.merge_strategy' => '1',
            'merge.edit_note' => 'This is an edit note',
        },
    });

    my $release_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    note('If the latest edit is a release merge, no RG merge was entered');
    isa_ok($release_edit, 'MusicBrainz::Server::Edit::Release::Merge');

    cmp_deeply($release_edit->data, {
        new_entity => {
            id => 6,
            name => 'The Prologue (disc 1)',
            labels => [],
            artist_credit => {
                names => [
                    {
                        artist => {
                            id => 1,
                            name => 'Name',
                        },
                        join_phrase => '',
                        name => 'Name',
                    },
                ],
            },
            mediums => [{
                format_name => undef,
                track_count => 1,
            }],
            events => [],
        },
        old_entities => [{
            id => 7,
            name => 'The Prologue (disc 2)',
            labels => [],
            artist_credit => {
                names => [
                    {
                        artist => {
                            id => 1,
                            name => 'Name',
                        },
                        join_phrase => '',
                        name => 'Name',
                    },
                ],
            },
            mediums => [{
                format_name => undef,
                track_count => 1,
            }],
            events => [],
        }],
        merge_strategy => 1,
        _edit_version => 3,
        medium_changes => bag(
            {
                release => {
                    id => 6,
                    name => 'The Prologue (disc 1)',
                },
                mediums => [{
                    id => 2,
                    old_position => 1,
                    new_position => 1,
                    old_name => '',
                    new_name => '',
                }],
            },
            {
                release => {
                    id => 7,
                    name => 'The Prologue (disc 2)',
                },
                mediums => [{
                    id => 3,
                    old_position => 1,
                    new_position => 2,
                    old_name => '',
                    new_name => '',
                }],
            },
        ),
    }, 'The release merge edit was still entered and contains the expected data');
};

test 'Release groups are entered for merge just once each (MBS-14124)' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/release/merge_queue?add-to-merge=6');
    $mech->get_ok('/release/merge_queue?add-to-merge=7');
    $mech->get_ok('/release/merge_queue?add-to-merge=100');

    $mech->get_ok('/release/merge');
    $mech->submit_form_ok({
        with_fields => {
            'merge.target' => '100',
            'merge.medium_positions.map.0.position' => '1',
            'merge.medium_positions.map.1.position' => '2',
            'merge.medium_positions.map.2.position' => '3',
            'merge.merge_rgs' => '1',
            'merge.merge_strategy' => '1',
            'merge.edit_note' => 'This is an edit note',
        },
    });

    my $rg_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($rg_edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');

    cmp_deeply($rg_edit->data, {
        new_entity => {
            id => 100,
            name => 'Pregap?',
        },
        old_entities => [{
            id => 1,
            name => 'Arrival',
        }],
    });

    my $release_edit = $test->c->model('Edit')->get_by_id($rg_edit->id - 1);
    isa_ok($release_edit, 'MusicBrainz::Server::Edit::Release::Merge');
};

test 'Edit note is required' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/release/merge_queue?add-to-merge=6');
    $mech->get_ok('/release/merge_queue?add-to-merge=7');

    $mech->get_ok('/release/merge');
    $mech->submit_form_ok({
        with_fields => {
            'merge.target' => '6',
            'merge.merge_strategy' => '1',
        },
    });
    $mech->content_contains('You must provide an edit note', 'contains warning about edit note being required');
};

1;
