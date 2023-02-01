package t::MusicBrainz::Server::Controller::Series::AddAnnotation;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Edit', 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether adding annotations for series works, including
whether four spaces at the start of the annotation are left untrimmed
(for list syntax).

=cut

test 'Adding series annotations' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edit_annotation',
        'Fetched the edit annotation page',
    );
    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-annotation.text' => "    * Test annotation\x{0007} for a series  \r\n\r\n\t\x{00A0}\r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
                'edit-annotation.changelog' => 'Changelog here',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ qr{/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/?$},
        'The user is redirected to the series page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::AddAnnotation');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                name => 'Test Recording Series',
            },
            text => "    * Test annotation for a series\n\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets",
            changelog => 'Changelog here',
            editor_id => 1,
            old_annotation_id => undef,
        },
        'The edit contains the right data (with untrimmed initial spaces)',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');

    $mech->content_contains('Changelog here', 'Edit page contains changelog');
    $mech->content_contains(
        'Test Recording Series',
        'Edit page contains series name',
    );
    $mech->content_like(
        qr{series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/?"},
        'Edit page has a link to the series',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
