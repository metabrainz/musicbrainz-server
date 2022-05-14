package t::MusicBrainz::Server::Controller::Mood::Create;
use Test::Routine;
use Test::More;
use utf8;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic mood creation works. It also ensures
unprivileged users cannot create moods.

=cut

test 'Adding a new mood' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mood_editing');

    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => { username => 'mood_editor', password => 'pass' }
    );

    $mech->get_ok(
        '/mood/create',
        'Fetched the mood creation page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->post_ok(
            '/mood/create',
            {
                'edit-mood.comment' => 'A comment!',
                'edit-mood.name' => 'super sad',
                'edit-mood.edit_note' => '😢'
            },
            'The form returned a 2xx response code'
        );
    } $c;

    ok(
        $mech->uri =~ qr{/mood/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})$},
        'The user is redirected to the mood page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Mood::Create');

    is_deeply(
        $edit->data,
        {
            name          => 'super sad',
            comment       => 'A comment!',
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'super sad',
        'The edit page contains the mood name',
    );
    $mech->text_contains(
        'A comment!',
        'The edit page contains the disambiguation',
    );
    $mech->text_contains(
        '😢',
        'The edit page contains the edit note',
    );
};

test 'Mood creation is blocked for unprivileged users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mood_editing');

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'boring_editor', password => 'pass' });
    $mech->get('/mood/create');
    is(
        $mech->status,
        403,
        'Trying to add a mood without the right privileges gives a 403 Forbidden error',
    );
};

1;
