package t::MusicBrainz::Server::Controller::Recording::AddAnnotation;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether adding annotations for recordings works, including
whether four spaces at the start of the annotation are left untrimmed
(for list syntax).

=cut

test 'Adding recording annotations' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok(
        '/recording/123c079d-374e-4436-9448-da92dedef3ce/edit_annotation',
        'Fetched the edit annotation page',
    );
    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-annotation.text' => "    * Test annotation\N{BEL} for a recording  \r\n\r\n\t\N{NO-BREAK SPACE}\r\n    * This anno\N{ZERO WIDTH SPACE}tation has\ttwo bul\N{SOFT HYPHEN}lets  \t\t",
                'edit-annotation.changelog' => 'Changelog here',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ qr{/recording/123c079d-374e-4436-9448-da92dedef3ce/?$},
        'The user is redirected to the recording page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddAnnotation');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                name => 'Dancing Queen',
            },
            text => "    * Test annotation for a recording\n\n    * This anno\N{ZERO WIDTH SPACE}tation has\ttwo bul\N{SOFT HYPHEN}lets",
            changelog => 'Changelog here',
            editor_id => 1,
            old_annotation_id => 3,
        },
        'The edit contains the right data (with untrimmed initial spaces)',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');

    $mech->content_contains('Changelog here', 'Edit page contains changelog');
    $mech->content_contains(
        'Dancing Queen',
        'Edit page contains recording name',
    );
    $mech->content_like(
        qr{recording/123c079d-374e-4436-9448-da92dedef3ce/?"},
        'Edit page has a link to the recording',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
