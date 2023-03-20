package t::MusicBrainz::Server::Controller::CDTOC::SetDurations;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the set track lengths page for disc IDs allows
entering edits.

=cut

test 'Setting track lengths based on disc ID' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_cdtoc');

    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO editor (
            id, name, password, privs,
            email, website, bio,
            email_confirm_date, member_since, last_login_date, ha1
        ) VALUES (
            1, 'new_editor', '{CLEARTEXT}password', 0,
            'test@editor.org', 'http://musicbrainz.org', 'biography',
            '2005-10-20', '1989-07-23', now(), 'e1dd8fee8ee728b0ddc8027d3a3db478'
        );
        SQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok(
        '/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-/set-durations?medium=1',
        'Fetched set durations for medium page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'confirm.edit_note' => 'Update the durations!',
            }
        },
        'The form returned a 2xx response code')
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $cdtoc = $c->model('CDTOC')->get_by_discid('tLGBAiCflG8ZI6lFcOt87vXjEcI-');

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');
    is(
        $edit->data->{medium_id},
        1,
        'The edit data contains the right medium id',
    );
    is(
        $edit->data->{cdtoc}{id},
        $cdtoc->id,
        'The edit data contains the right CD TOC id',
    );

    like(
        $mech->uri,
        qr{/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-$},
        'The user is redirected to the disc ID page',
    );
    $mech->content_contains(
        'Thank you, your <a href="',
        'The user is notified that they entered an edit',
    );

    my $edit_title = 'Edit #' . $edit->id;

    $mech->get_ok(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/edits',
        'Fetch changed recording edit history',
    );

    $mech->content_contains(
        $edit_title,
        'The edit history for the changed recording includes the edit',
    );

    $mech->get_ok(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b1/edits',
        'Fetch unchanged recording edit history',
    );

    $mech->content_lacks(
        $edit_title,
        'The edit history for the unchanged recording does not include the edit',
    );
};

1;
