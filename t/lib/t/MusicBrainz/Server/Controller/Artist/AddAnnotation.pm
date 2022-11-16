package t::MusicBrainz::Server::Controller::Artist::AddAnnotation;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );
use Time::HiRes qw( gettimeofday tv_interval );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether adding annotations for artists works, including
whether four spaces at the start of the annotation are left untrimmed
(for list syntax). It also checks whether too long changelogs are detected
and blocked.

=cut

test 'MBS-4091: Test submitting annotation starting with list syntax' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation');
    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-annotation.text' => "    * Test annotation\x{0007} for an artist  \r\n\r\n\t\x{00A0}\r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
                'edit-annotation.changelog' => 'Changelog here',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce/?$},
        'The user is redirected to the artist page after entering the edit');

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAnnotation');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 3,
                name => 'Test Artist',
            },
            text => "    * Test annotation for an artist\n\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets",
            changelog => 'Changelog here',
            editor_id => 1,
            old_annotation_id => 1,
        },
        'The edit contains the right data (with untrimmed initial spaces)',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');

    $mech->content_contains('Changelog here', 'Edit page contains changelog');
    $mech->content_contains('Test Artist', 'Edit page contains artist name');
    $mech->content_like(
        qr{artist/745c079d-374e-4436-9448-da92dedef3ce/?"},
        'Edit page has a link to the artist',
    );
};

test 'MBS-12161: Test submitting annotation with too long changelog' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation');
    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-annotation.text' => "    * Test annotation\x{0007} for an artist  \r\n\r\n\t\x{00A0}\r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
                'edit-annotation.changelog' => 'This is a very long changelog that will indeed exceed the maximum allowed length and should trigger an error, but it did not, leading to MBS-12161. That has hopefully been fixed, so this intentionally ridiculously long changelog should now return an error as it was meant to do.',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation?$},
        'The edit annotation page is shown again',
    );

    is(@edits, 0, 'No edit was entered');

    $mech->content_contains(
        'Field should not exceed 255 characters. You entered 278',
        'The "too long changelog" error is shown',
    );
};

test 'MBS-12302: Test large annotation diffing' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    my @edits = capture_edits {
        $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation');
        $mech->submit_form_ok({
            with_fields => {
                'edit-annotation.text' => 'HA HA HA',
                'edit-annotation.changelog' => '',
            },
        },
        'The form returned a 2xx response code');

        $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation');
        $mech->submit_form_ok({
            with_fields => {
                'edit-annotation.text' => 'HA HO HA',
                'edit-annotation.changelog' => '',
            },
        },
        'The form returned a 2xx response code');
    } $test->c;

    ok(
        $mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce/?$},
        'The user is redirected to the artist page after entering the edit');

    is(@edits, 2, 'The edits were entered');

    my $edit = pop(@edits);
    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');

    $mech->content_contains(
        '<th>Annotation comparison:</th>' .
        '<td class="old">HA <span class="diff-only-a">HA</span> HA</td>' .
        '<td class="new">HA <span class="diff-only-b">HO</span> HA</td>',
        'Small annotation comparison uses word diffing',
    );

    my $lots_o_hes = ('HE ' x 398) . 'HE';

    @edits = capture_edits {
        $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation');
        $mech->submit_form_ok({
            with_fields => {
                'edit-annotation.text' => 'HO HA HO HE ' . $lots_o_hes,
                'edit-annotation.changelog' => '',
            },
        },
        'The form returned a 2xx response code');
    } $test->c;

    my $t0 = [gettimeofday];

    $edit = pop(@edits);
    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');

    # MBS-12302: Diffs with text larger than 1024 characters fall back to
    # (fast) character diffing.

    my $interval = tv_interval($t0);
    ok($interval < 1, 'Large Add Annotation diff took less than 1 second to load');

    $mech->content_contains(
        '<th>Annotation comparison:</th>' .
        '<td class="old">HA HO H<span class="diff-only-a">A</span></td>' .
        '<td class="new"><span class="diff-only-b">HO </span>HA HO H<span class="diff-only-b">E ' . $lots_o_hes . '</span></td>',
        'Large annotation comparison uses character diffing',
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
