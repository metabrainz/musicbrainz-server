package t::MusicBrainz::Server::Controller::Instrument::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic instrument editing works. It also ensures
unprivileged users cannot edit instruments.

=cut

test 'Editing an instrument' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+instrument_editing',
    );

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'instrument_editor', password => 'pass' }
    );

    $mech->get_ok(
        '/instrument/945c079d-374e-4436-9448-da92dedef3cf/edit',
        'Fetched the instrument editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => { 'edit-instrument.name' => 'ornitorrinco' },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/instrument/945c079d-374e-4436-9448-da92dedef3cf$},
        'The user is redirected to the instrument page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Instrument::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                gid => '945c079d-374e-4436-9448-da92dedef3cf',
                id => 1,
                name => 'Minimal Instrument',
            },
            new => { name => 'ornitorrinco' },
            old => { name => 'Minimal Instrument' },
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'Minimal Instrument',
        'The edit page contains the old instrument name',
    );
    $mech->text_contains(
        'ornitorrinco',
        'The edit page contains the new instrument name',
    );
};

test 'Instrument editing is blocked for unprivileged users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+instrument_editing',
    );

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'boring_editor', password => 'pass' }
    );

    $mech->get('/instrument/945c079d-374e-4436-9448-da92dedef3cf/edit');
    is(
        $mech->status,
        403,
        'Trying to edit an instrument without the right privileges gives a 403 Forbidden error',
    );
};

1;
