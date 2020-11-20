package t::MusicBrainz::Server::Controller::Event::ReorderEventArt;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'Reordering event art' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+eaa');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO edit (id, editor, type, status, expire_time)
             VALUES (2, 10, 1510, 2, now());
        INSERT INTO edit_data (edit, data)
             VALUES (2, '{}');

        INSERT INTO event_art_archive.event_art (id, event, mime_type, edit, ordering)
             VALUES (12346, 59357, 'image/jpeg', 2, 2);
        SQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'eaa_editor', password => 'password' } );

    $mech->get_ok('/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/reorder-event-art');

    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'reorder-event-art.artwork.0.id' => 12345,
                'reorder-event-art.artwork.0.position' => 1,
                'reorder-event-art.artwork.1.id' => 12346,
                'reorder-event-art.artwork.1.position' => 2,
            },
        );
    } $c;
    is(@edits, 0, 'does not create edit without changes');

    $mech->get_ok('/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/reorder-event-art');

    @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'reorder-event-art.artwork.0.id' => 12345,
                'reorder-event-art.artwork.0.position' => 2,
                'reorder-event-art.artwork.1.id' => 12346,
                'reorder-event-art.artwork.1.position' => 1,
            },
        );
    } $c;

    is(@edits, 1);
    my ($edit) = @edits;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Event::ReorderEventArt');
    my $data = $edit->data;

    is_deeply(
        $data->{new},
        [ { id => 12345, position => 2 } ,
          { id => 12346, position => 1 } ],
        'Correctly reorders artwork',
    );
};

1;
