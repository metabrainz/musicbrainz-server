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
        'merge.edit_note' => 'Mandatory'
    }
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
                        name => 'Name'
                    },
                    join_phrase => '',
                    name => 'Name'
                }
            ]
        },
        mediums => [{
            format_name => undef,
            track_count => 1
        }],
        events => []
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
                        name => 'Name'
                    },
                    join_phrase => '',
                    name => 'Name'
                }
            ]
        },
        mediums => [{
            format_name => undef,
            track_count => 1
        }],
        events => []
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
            }]
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
            }]
        },
    )
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
        'merge.edit_note' => 'Empty Edit Note'
    }
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
                        name => 'Name'
                    },
                    join_phrase => '',
                    name => 'Name'
                }
            ]
        },
        mediums => [{
            format_name => undef,
            track_count => 1
        }],
        events => []
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
                        name => 'Name'
                    },
                    join_phrase => '',
                    name => 'Name'
                }
            ]
        },
        mediums => [{
            format_name => undef,
            track_count => 1
        }],
        events => []
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
            }]
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
            }]
        },
    )
});

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
        }
    });
    $mech->content_contains('You must provide an edit note', 'contains warning about edit note being required');
};

1;
