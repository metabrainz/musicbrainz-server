package t::MusicBrainz::Server::Controller::Label::AddAnnotation;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether adding annotations for labels works, including
whether four spaces at the start of the annotation are left untrimmed
(for list syntax).

=cut

test 'Adding label annotations' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok(
        '/label/4b4ccf60-658e-11de-8a39-0800200c9a66/edit_annotation',
        'Fetched the edit annotation page',
    );
    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-annotation.text' => "    * Test annotation\x{0007} for a label  \r\n\r\n\t\x{00A0}\r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
                'edit-annotation.changelog' => 'Changelog here',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ qr{/label/4b4ccf60-658e-11de-8a39-0800200c9a66/?$},
        'The user is redirected to the label page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::AddAnnotation');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 3,
                name => 'Another Label',
            },
            text => "    * Test annotation for a label\n\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets",
            changelog => 'Changelog here',
            editor_id => 1,
            old_annotation_id => undef,
        },
        'The edit contains the right data (with untrimmed initial spaces)',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');

    $mech->content_contains('Changelog here', 'Edit page contains changelog');
    $mech->content_contains('Another Label', 'Edit page contains label name');
    $mech->content_like(
        qr{label/4b4ccf60-658e-11de-8a39-0800200c9a66/?"},
        'Edit page has a link to the label',
    );
};

1;
