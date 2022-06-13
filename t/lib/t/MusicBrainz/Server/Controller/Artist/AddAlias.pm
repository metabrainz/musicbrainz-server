package t::MusicBrainz::Server::Controller::Artist::AddAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether alias adding for artists works, including whether
the sort name defaults to the name when not explicitly entered.

=cut

test 'Adding alias with sort name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/add-alias',
        'Fetched the add alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-alias.name' => 'An alias',
                'edit-alias.sort_name' => 'Artist, Test',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAlias');
    is_deeply(
        $edit->data,
        {
            locale => undef,
            entity => {
                id => 3,
                name => 'Test Artist'
            },
            name => 'An alias',
            sort_name => 'Artist, Test',
            primary_for_locale => 0,
            begin_date => {
                year => undef,
                month => undef,
                day => undef
            },
            end_date => {
                year => undef,
                month => undef,
                day => undef
            },
            type_id => undef,
            ended => 0,
        },
        'The edit contains the right data',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);

    $mech->content_contains('Test Artist', 'Edit page contains artist name');
    $mech->content_contains(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce',
        'Edit page contains artist link',
    );
    $mech->content_contains('An alias', 'Edit page contains alias name');
    $mech->content_contains(
        'Artist, Test',
        'Edit page contains the selected alias sort name',
    );
};

test 'MBS-6896: Adding alias without sort name defaults it to name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/add-alias',
        'Fetched the add alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-alias.name' => 'Another alias',
            }
        },
        'The form returned a 2xx response code')
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAlias');
    is(
        $edit->data->{sort_name},
        'Another alias',
        'The (not specified) sort name in the edit data defaults to the name',
    );
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+controller_artist',
    );

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );
}

1;
