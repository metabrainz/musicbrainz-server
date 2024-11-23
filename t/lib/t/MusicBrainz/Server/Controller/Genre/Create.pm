package t::MusicBrainz::Server::Controller::Genre::Create;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether basic genre creation works. It also ensures
unprivileged users cannot create genres.

=cut

test 'Adding a new genre' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+genre_editing');

    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => { username => 'genre_editor', password => 'pass' },
    );

    $mech->get_ok(
        '/genre/create',
        'Fetched the genre creation page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->post_ok(
            '/genre/create',
            {
                'edit-genre.comment' => 'A comment!',
                'edit-genre.name' => 'surrogate stone',
                'edit-genre.edit_note' => 'Totally not just alternative rock.',
            },
            'The form returned a 2xx response code',
        );
    } $c;

    ok(
        $mech->uri =~ qr{/genre/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})$},
        'The user is redirected to the genre page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Genre::Create');

    is_deeply(
        $edit->data,
        {
            name          => 'surrogate stone',
            comment       => 'A comment!',
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'surrogate stone',
        'The edit page contains the genre name',
    );
    $mech->text_contains(
        'A comment!',
        'The edit page contains the disambiguation',
    );
    $mech->text_contains(
        'Totally not just alternative rock.',
        'The edit page contains the edit note',
    );
};

test 'Genre creation is blocked for unprivileged users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+genre_editing');

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'boring_editor', password => 'pass' });
    $mech->get('/genre/create');
    is(
        $mech->status,
        HTTP_FORBIDDEN,
        'Trying to add a genre without the right privileges gives a 403 Forbidden error',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
