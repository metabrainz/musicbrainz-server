package t::MusicBrainz::Server::Controller::Series::AddAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );
use utf8;

with 't::Edit', 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether alias adding for series works, including whether
the sort name defaults to the name when not explicitly entered.

=cut

test 'Adding alias with sort name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/add-alias',
        'Fetched the add alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-alias.name' => 'Now that’s what I call a series',
                'edit-alias.sort_name' => 'series, Now that’s what I call a',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::AddAlias');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                name => 'Test Recording Series',
            },
            name => 'Now that’s what I call a series',
            sort_name => 'series, Now that’s what I call a',
            locale => undef,
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

    $mech->content_contains(
        'Test Recording Series',
        'Edit page contains series name',
    );
    $mech->content_contains(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d',
        'Edit page contains series link',
    );
    $mech->content_contains(
        'Now that’s what I call a series',
        'Edit page contains alias name',
    );
    $mech->content_contains(
        'series, Now that’s what I call a',
        'Edit page contains the selected alias sort name',
    );
};

test 'MBS-6896: Adding alias without sort name defaults it to name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/add-alias',
        'Fetched the add alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-alias.name' => 'Now that’s what I call another series',
            }
        },
        'The form returned a 2xx response code')
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::AddAlias');
    is(
        $edit->data->{sort_name},
        'Now that’s what I call another series',
        'The (not specified) sort name in the edit data defaults to the name',
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
