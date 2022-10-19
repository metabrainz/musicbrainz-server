package t::MusicBrainz::Server::Controller::Genre::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description
This test checks whether basic genre editing works. It also ensures
unprivileged users cannot edit genres.
=cut

test 'Editing a genre' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+genre_editing');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'genre_editor', password => 'pass' }
    );

    $mech->get_ok(
        '/genre/ceeaa283-5d7b-4202-8d1d-e25d116b2a18/edit',
        'Fetched the genre editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => { 'edit-genre.name' => 'surrogate stone' },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/genre/ceeaa283-5d7b-4202-8d1d-e25d116b2a18$},
        'The user is redirected to the genre page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Genre::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                gid => 'ceeaa283-5d7b-4202-8d1d-e25d116b2a18',
                id => 1,
                name => 'alternative rock',
            },
            new => { name => 'surrogate stone' },
            old => { name => 'alternative rock' },
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'alternative rock',
        'The edit page contains the old genre name',
    );
    $mech->text_contains(
        'surrogate stone',
        'The edit page contains the new genre name',
    );
};

test 'Genre editing is blocked for unprivileged users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+genre_editing');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'boring_editor', password => 'pass' }
    );

    $mech->get('/genre/ceeaa283-5d7b-4202-8d1d-e25d116b2a18/edit');
    is(
        $mech->status,
        403,
        'Trying to edit a genre without the right privileges gives a 403 Forbidden error',
    );
};

1;
