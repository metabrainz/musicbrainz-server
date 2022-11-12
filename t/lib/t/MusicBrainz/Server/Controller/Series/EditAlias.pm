package t::MusicBrainz::Server::Controller::Series::EditAlias;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Edit', 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether alias editing for series works, including whether
the sort name defaults to the name when not explicitly entered (blanked).
It also checks that editing an alias to be a search hint automatically sets
the sort name to match the name.

=cut

test 'Editing alias' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/alias/1/edit',
        'Fetched the edit alias page',
    );
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Edited alias',
                # HTML::Form doesn't understand selected=""
                # so we need to specifically set this
                'edit-alias.type_id' => '1',
            });
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::EditAlias');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                name => 'Test Recording Series'
            },
            alias_id  => 1,
            new => {
                name => 'Edited alias',
            },
            old => {
                name => 'Test Series Alias',
            }
        },
        'The edit contains the right data',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->content_contains(
        'Test Recording Series',
        'Edit page contains series name',
    );
    $mech->content_contains(
        'Test Series Alias',
        'Edit page contains old alias name',
    );
    $mech->content_contains(
        'Edited alias',
        'Edit page contains new alias name',
    );
};

test 'MBS-6896: Removing alias sort name defaults it to name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/alias/1/edit',
        'Fetched the edit alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Edit #2',
                'edit-alias.sort_name' => '',
            });
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::EditAlias');
    is(
        $edit->data->{new}{sort_name},
        'Edit #2',
        'The (not specified) sort name in the edit data defaults to the name',
    );
};

test 'Changing alias type to search hint overrides sort name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/alias/1/edit',
        'Fetched the edit alias page',
    );
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Edited alias',
                # Change to search hint
                'edit-alias.type_id' => '2',
            });
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::EditAlias');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                name => 'Test Recording Series'
            },
            alias_id  => 1,
            new => {
                name => 'Edited alias',
                sort_name => 'Edited alias',
                type_id => '2',
            },
            old => {
                name => 'Test Series Alias',
                sort_name => 'Test Series Alias',
                type_id => '1',
            }
        },
        'The edit contains the right data, including changed sort names',
    );
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+series');

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor', password => 'pass' }
    );
}

1;
