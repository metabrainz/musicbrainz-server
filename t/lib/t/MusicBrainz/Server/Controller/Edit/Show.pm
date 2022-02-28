package t::MusicBrainz::Server::Controller::Edit::Show;
use Test::Routine;

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_EDIT
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the shared components of edit display pages work as
expected for all kinds of editors: default / author / beginner / logged out.

=cut

test 'Check edit page displays basic components' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => {
        username => 'editor2',
        password => 'pass',
    } );

    $mech->get_ok(
        '/edit/' . $edit->id,
        'Fetched edit page as someone else than the edit author',
    );
    html_ok($mech->content);

    $mech->content_contains(
        'Accept upon closing',
        'The edit page mentions what will happen on expiration',
    );
    $mech->content_contains(
        '3 unanimous votes',
        'The edit page mentions the votes needed to close the edit early',
    );
    $mech->content_contains(
        'Submit vote and note',
        'The edit page contains the button to vote and add an edit note',
    );
    $mech->content_contains(
        'Edit by <a href="/user/editor1">',
        'The edit page lists the editor who entered the edit',
    )
};

test 'Check edit page differences for own edit' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => {
        username => 'editor1',
        password => 'pass',
    } );

    $mech->get_ok(
        '/edit/' . $edit->id,
        'Fetched edit page as the edit author',
    );
    html_ok($mech->content);

    $mech->content_contains(
        'Submit note',
        'The edit page contains the button to add an edit note',
    );
    $mech->content_lacks(
        'You are not currently able to vote on this edit',
        'The message about not being able to vote is not present',
    );
};

test 'Check edit page differences for beginner editor' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => {
        username => 'editor5',
        password => 'pass',
    } );

    $mech->get_ok(
        '/edit/' . $edit->id,
        'Fetched edit page as a beginner editor other than the edit author',
    );
    html_ok($mech->content);

    $mech->content_contains(
        'You are not currently able to vote on this edit',
        'The message about not being able to vote is present',
    );
    $mech->content_contains(
        'You are not currently able to add notes to this edit',
        'The message about not being able to add notes is present',
    );
};

test 'Check edit page differences when logged out' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test);

    $mech->get_ok(
        '/edit/' . $edit->id,
        'Fetched edit page while logged out',
    );
    html_ok($mech->content);

    $mech->content_contains(
        'Editor hidden',
        'The "Editor hidden" message is shown',
    );
    $mech->content_lacks(
        'editor1',
        'The editor name is not shown',
    );
    $mech->content_contains(
        'You must be logged in to see edit notes',
        'The edit notes are hidden',
    );
    $mech->content_contains(
        'You must be logged in to vote on edits',
        'The message about not being able to vote is present',
    );
    $mech->content_lacks(
        'Raw edit data for this edit',
        'The raw data link is hidden',
    );
};

sub prepare {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_ARTIST_EDIT,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'Changed comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    return $edit;
}

1;
