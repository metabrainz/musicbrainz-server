package t::MusicBrainz::Server::Controller::Series::DeleteAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Edit', 't::Mechanize', 't::Context';

=head2 Test description

This test checks that series alias deletion works, and that it requires
an edit note.

=cut

test 'Deleting an alias' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/alias/1/delete',
        'Fetched the delete alias page',
    );
    my @edits = capture_edits {
        $mech->submit_form_ok({
                with_fields => {
                    'confirm.edit_note' =>
                        q(Some edit note since it's required)
                }
            },
            'The form returned a 2xx response code',
        );
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::DeleteAlias');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                name => 'Test Recording Series'
            },
            alias_id  => 1,
            name      => 'Test Series Alias',
            sort_name => 'Test Series Alias',
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
            ended => 0,
            type_id => 1,
            locale => undef,
            primary_for_locale => 0,
        },
        'The edit contains the right data',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');
    html_ok($mech->content);
    $mech->content_contains(
        'Test Recording Series',
        'The edit page contains the series name',
    );
    $mech->content_contains(
        'Test Series Alias',
        'The edit page contains the alias name',
    );
};

test 'Edit note is required' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/alias/1/delete',
        'Fetched the delete alias page',
    );
    my @edits = capture_edits {
        $mech->submit_form_ok({
                with_fields => {
                    'confirm.edit_note' => ''
                }
            },
            'The form returned a 2xx response code',
        );
    } $test->c;

    is(@edits, 0, 'No edit was entered');

    $mech->content_contains(
        'You must provide an edit note',
        'Contains warning about edit note being required',
    );
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+series');

    $test->mech->get_ok('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor', password => 'pass' },
    );
}

1;
