package t::MusicBrainz::Server::Controller::Edit::Cancel;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_EDIT
    $STATUS_APPLIED
    $STATUS_DELETED
    $UNTRUSTED_FLAG
);

with 't::Context', 't::Mechanize';

=head2 Test description

This test checks whether an editor's open edits can be cancelled, whether
the cancel page leaves edit notes appropriately, and whether cancelling edits
is blocked when it makes no sense.

=cut

test 'Cancelling edits' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test, 'editor1');

    $mech->get_ok(
        '/edit/' . $edit->id . '/cancel',
        'Fetched cancel edit page',
    );
    $mech->content_contains(
        'Changed comment',
        'The cancel page displays edit details',
    );
    $mech->submit_form_ok({
            with_fields => { 'confirm.edit_note' => '' },
        },
        'The form returned a 2xx response code',
    );

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $test->c->model('EditNote')->load_for_edits($edit);
    is($edit->status, $STATUS_DELETED, 'The edit was cancelled');
    is(
        $edit->all_edit_notes,
        0,
        'No edit note was added',
    );
};

test 'Cancelling edits with an optional edit note' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test, 'editor1');

    $mech->get_ok(
        '/edit/' . $edit->id . '/cancel',
        'Fetched cancel edit page',
    );
    $mech->submit_form_ok({
            with_fields => { 'confirm.edit_note' => 'Hello tests!' },
        },
        'The form returned a 2xx response code',
    );

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    is($edit->status, $STATUS_DELETED, 'The edit was cancelled');
    $test->c->model('EditNote')->load_for_edits($edit);
    is(
        $edit->all_edit_notes,
        1,
        'The edit has an edit note',
    );
    is(
        $edit->edit_notes->[0]->text,
        'Hello tests!',
        'The edit note has the expected text',
    );
    is(
        $edit->edit_notes->[0]->editor_id,
        1,
        'The edit note has the expected editor',
    );
};

test 'Cannot cancel a cancelled edit' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test, 'editor1');

    $mech->get_ok(
        '/edit/' . $edit->id . '/cancel',
        'Fetched cancel edit page',
    );
    $mech->submit_form_ok({
            with_fields => { 'confirm.edit_note' => 'Hello tests!' },
        },
        'The form returned a 2xx response code',
    );

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    is($edit->status, $STATUS_DELETED, 'The edit was cancelled');

    $mech->get_ok(
        '/edit/' . $edit->id . '/cancel',
        'Fetched cancel edit page again',
    );

    $mech->content_contains(
        'Error Cancelling Edit',
        'The "cannot cancel edit" page is displayed',
    );
    $mech->content_contains(
        'The edit has already been closed',
        'The reason the edit cannot be cancelled is displayed',
    );
    ok(
        !defined $mech->form_with_fields('confirm.edit_note'),
        'There is no edit note form',
    );
};

test 'Cannot cancel an accepted edit' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test, 'editor1');

    $test->c->model('Edit')->accept($edit);
    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    is($edit->status, $STATUS_APPLIED, 'The edit was applied');

    $mech->get_ok(
        '/edit/' . $edit->id . '/cancel',
        'Fetched cancel edit page again',
    );

    $mech->content_contains(
        'Error Cancelling Edit',
        'The "cannot cancel edit" page is displayed',
    );
    $mech->content_contains(
        'The edit has already been closed',
        'The reason the edit cannot be cancelled is displayed',
    );
    ok(
        !defined $mech->form_with_fields('confirm.edit_note'),
        'There is no edit note form',
    );
};

test q(Cannot cancel someone else's edit) => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test, 'editor2');

    $mech->get_ok(
        '/edit/' . $edit->id . '/cancel',
        'Fetched cancel edit page',
    );
    $mech->content_contains(
        'Error Cancelling Edit',
        'The "cannot cancel edit" page is displayed',
    );
    $mech->content_contains(
        'Only the editor who created an edit can cancel it',
        'The reason the edit cannot be cancelled is displayed',
    );
    ok(
        !defined $mech->form_with_fields('confirm.edit_note'),
        'There is no edit note form',
    );
};

sub prepare {
    my ($test, $login_as) = @_;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, 'e69a970a-e916-11e0-a751-00508db50876', 'artist', 'artist');
        INSERT INTO editor (id, name, password, email, ha1, email_confirm_date)
            VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee', now()),
                   (2, 'editor2', '{CLEARTEXT}pass', 'editor2@example.com', '16a4862191803cb596ee4b16802bb7ef', now());
        SQL

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_ARTIST_EDIT,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'Changed comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => $login_as, password => 'pass' } );

    return $edit;
}

1;
