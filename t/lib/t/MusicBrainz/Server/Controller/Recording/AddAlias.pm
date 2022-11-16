package t::MusicBrainz::Server::Controller::Recording::AddAlias;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether alias adding for recordings works, including whether
the sort name defaults to the name when not explicitly entered.

=cut

test 'Adding alias with sort name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/add-alias',
        'Fetched the add alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-alias.name' => 'Now that’s what I call a recording',
                'edit-alias.sort_name' => 'recording, Now that’s what I call a'
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddAlias');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                name => 'King of the Mountain',
            },
            name => 'Now that’s what I call a recording',
            sort_name => 'recording, Now that’s what I call a',
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
        'King of the Mountain',
        'Edit page contains series name',
    );
    $mech->content_contains(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b8',
        'Edit page contains series link',
    );
    $mech->content_contains(
        'Now that’s what I call a recording',
        'Edit page contains alias name',
    );
    $mech->content_contains(
        'recording, Now that’s what I call a',
        'Edit page contains the selected alias sort name',
    );
};

test 'MBS-6896: Adding alias without sort name defaults it to name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/add-alias',
        'Fetched the add alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-alias.name' => 'Now that’s what I call another recording',
            }
        },
        'The form returned a 2xx response code')
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddAlias');
    is(
        $edit->data->{sort_name},
        'Now that’s what I call another recording',
        'The (not specified) sort name in the edit data defaults to the name',
    );
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+recording');

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor', password => 'password' }
    );
}

1;
