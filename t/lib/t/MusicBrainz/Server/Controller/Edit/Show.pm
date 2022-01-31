package t::MusicBrainz::Server::Controller::Edit::Show;
use Test::Routine;

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_EDIT
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test 'Check edit page displays basic components' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/login');
    $test->mech->submit_form( with_fields => {
        username => 'editor2',
        password => 'pass',
    } );

    $test->mech->get_ok('/edit/' . $edit->id, 'fetch edit page');
    html_ok($test->mech->content);

    $test->mech->content_contains(
        'Accept upon closing',
        'mentions expire action',
    );
    $test->mech->content_contains(
        '3 unanimous votes',
        'mentions vote conditions',
    );
    $test->mech->content_contains(
        'Submit vote and note',
        'contains voting button',
    );
    $test->mech->content_contains(
        'Edit by <a href="/user/editor1">',
        'mentions edit editor',
    )
};

test 'Check edit page differences for own edit' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/login');
    $test->mech->submit_form( with_fields => {
        username => 'editor1',
        password => 'pass',
    } );

    $test->mech->get_ok('/edit/' . $edit->id, 'fetch edit page');
    html_ok($test->mech->content);

    $test->mech->content_contains(
        'Submit note',
        'contains note button',
    );
    $test->mech->content_lacks(
        'You are not currently able to vote on this edit',
        'cannot vote message is not present',
    );
};

test 'Check edit page differences for beginner editor' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/login');
    $test->mech->submit_form( with_fields => {
        username => 'editor5',
        password => 'pass',
    } );

    $test->mech->get_ok('/edit/' . $edit->id, 'fetch edit page');
    html_ok($test->mech->content);

    $test->mech->content_contains(
        'You are not currently able to vote on this edit',
        'cannot vote message is present',
    );
    $test->mech->content_contains(
        'You are not currently able to add notes to this edit',
        'cannot add notes message is present',
    );
};

test 'Check edit page differences when logged out' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/edit/' . $edit->id, 'fetch edit page');
    html_ok($test->mech->content);

    $test->mech->content_contains('Editor hidden', 'editor hidden is shown');
    $test->mech->content_lacks('editor1', 'and editor name is hidden');
    $test->mech->content_contains(
        'You must be logged in to see edit notes',
        'edit notes are hidden',
    );
    $test->mech->content_contains(
        'You must be logged in to vote on edits',
        'cannot vote message is present',
    );
    $test->mech->content_lacks(
        'Raw edit data for this edit',
        'raw data link is hidden',
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
