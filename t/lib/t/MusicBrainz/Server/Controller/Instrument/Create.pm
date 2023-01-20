package t::MusicBrainz::Server::Controller::Instrument::Create;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic instrument creation works. It also ensures
unprivileged users cannot create instruments.

=cut

test 'Adding a new instrument' => sub {
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
        '/instrument/create',
        'Fetched the instrument creation page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-instrument.comment' => 'a newly invented instrument',
                'edit-instrument.description' => 'This is made up!',
                'edit-instrument.name' => 'New Instrument',
            },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/instrument/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})},
        'The user is redirected to the instrument page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Instrument::Create');

    is_deeply(
        $edit->data,
        {
            comment => 'a newly invented instrument',
            description => 'This is made up!',
            name => 'New Instrument',
            type_id => undef,
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'New Instrument',
        'The edit page contains the instrument name',
    );
    $mech->text_contains(
        'This is made up!',
        'The edit page contains the instrument description',
    );
    $mech->text_contains(
        'a newly invented instrument',
        'The edit page contains the disambiguation',
    );
};

test 'Instrument creation is blocked for unprivileged users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+instrument_editing',
    );

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'boring_editor', password => 'pass' });
    $mech->get('/instrument/create');
    is(
        $mech->status,
        403,
        'Trying to add an instrument without the right privileges gives a 403 Forbidden error',
    );
};

1;
