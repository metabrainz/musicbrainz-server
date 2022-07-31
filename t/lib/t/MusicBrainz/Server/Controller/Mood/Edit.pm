package t::MusicBrainz::Server::Controller::Mood::Edit;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description
This test checks whether basic mood editing works. It also ensures
unprivileged users cannot edit moods.
=cut

test 'Editing a mood' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mood_editing');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'mood_editor', password => 'pass' }
    );

    $mech->get_ok(
        '/mood/ceeaa283-5d7b-4202-8d1d-e25d116b2a18/edit',
        'Fetched the mood editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => { 'edit-mood.name' => 'super sad' },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/mood/ceeaa283-5d7b-4202-8d1d-e25d116b2a18$},
        'The user is redirected to the mood page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Mood::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                gid => 'ceeaa283-5d7b-4202-8d1d-e25d116b2a18',
                id => 1,
                name => 'depressive',
            },
            new => { name => 'super sad' },
            old => { name => 'depressive' },
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'depressive',
        'The edit page contains the old mood name',
    );
    $mech->text_contains(
        'super sad',
        'The edit page contains the new mood name',
    );
};

test 'Mood editing is blocked for unprivileged users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mood_editing');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'boring_editor', password => 'pass' }
    );

    $mech->get('/mood/ceeaa283-5d7b-4202-8d1d-e25d116b2a18/edit');
    is(
        $mech->status,
        403,
        'Trying to edit a mood without the right privileges gives a 403 Forbidden error',
    );
};

1;
