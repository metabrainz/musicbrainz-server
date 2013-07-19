package t::MusicBrainz::Server::Controller::Edit::Cancel;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Constants qw( $STATUS_DELETED );

with 't::Context', 't::Mechanize';

test 'Cancelling edits' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/edit/' . $edit->id . '/cancel');
    $test->mech->content_contains('Changed comment', 'displays edit details');
    $test->mech->submit_form(
        with_fields => {
            'confirm.edit_note' => ''
        }
    );

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $test->c->model('EditNote')->load_for_edits($edit);
    is($edit->all_edit_notes => 0);
    is($edit->status, $STATUS_DELETED);
};

test 'Cancelling edits with an optional edit note' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/edit/' . $edit->id . '/cancel');
    $test->mech->submit_form(
        with_fields => {
            'confirm.edit_note' => 'Hello tests!'
        }
    );

    $test->c->model('EditNote')->load_for_edits($edit);
    is($edit->all_edit_notes => 1);
    is($edit->edit_notes->[0]->text, 'Hello tests!');
    is($edit->edit_notes->[0]->editor_id, 1);
};

test 'Cannot cancel a cancelled edit' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/edit/' . $edit->id . '/cancel');
    $test->mech->submit_form(
        with_fields => {
            'confirm.edit_note' => 'Hello tests!'
        }
    );

    $test->mech->get_ok('/edit/' . $edit->id . '/cancel');
    ok(!defined $test->mech->form_with_fields('confirm.edit_note'));
};

sub prepare {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'artist');
INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, 'e69a970a-e916-11e0-a751-00508db50876', 1, 1);
INSERT INTO editor (id, name, password, email, ha1) VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee')
EOSQL

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_ARTIST_EDIT,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'Changed comment',
        ipi_codes => [],
        isni_codes => [],
    );

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    return $edit;
}

1;
