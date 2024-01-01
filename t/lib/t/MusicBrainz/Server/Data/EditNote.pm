package t::MusicBrainz::Server::Data::EditNote;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Exception;
use Test::Fatal;
use utf8;

BEGIN { use MusicBrainz::Server::Data::Gender }

use MusicBrainz::Server::Constants qw(
    :vote
);
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::EditNote;
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test;

with 't::Context';

BEGIN {
    package MockEdit;
    use Moose;
    use namespace::autoclean;

    extends 'MusicBrainz::Server::Edit';

    sub edit_type { 111; }
    sub edit_name { 'mock edit' }
}

use MusicBrainz::Server::EditRegistry;
MusicBrainz::Server::EditRegistry->register_type('MockEdit');

test 'Loading existing notes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_note');

    note('Check edit that should have two notes');
    my $edit = $c->model('Edit')->get_by_id(1);
    $c->model('EditNote')->load_for_edits($edit);
    is(@{ $edit->edit_notes }, 2, 'Edit has two edit notes');
    check_note(
        $edit->edit_notes->[0],
        'MusicBrainz::Server::Entity::EditNote',
        (
            editor_id => 1,
            edit_id => 1,
            text => 'This is a note',
        ),
    );

    check_note(
        $edit->edit_notes->[1],
        'MusicBrainz::Server::Entity::EditNote',
        (
            editor_id => 2,
            edit_id => 1,
            text => 'This is a later note',
        ),
    );

    note('Check edit that should have one note');
    $edit = $c->model('Edit')->get_by_id(2);
    $c->model('EditNote')->load_for_edits($edit);
    is(@{ $edit->edit_notes }, 1, 'Edit has one edit note');
    check_note(
        $edit->edit_notes->[0],
        'MusicBrainz::Server::Entity::EditNote',
        (
            editor_id => 1,
            edit_id => 2,
            text => 'Another edit note',
        ),
    );

    note('Check edit that should have zero notes');
    $edit = $c->model('Edit')->get_by_id(3);
    $c->model('EditNote')->load_for_edits($edit);
    is(@{ $edit->edit_notes }, 0, 'Edit has no edit notes');
};

test 'Adding edit notes works and sends emails when it should' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_note');

    my $editor2 = $c->model('Editor')->get_by_id(2);

    my $edit = $c->model('Edit')->get_by_id(3);
    my $edit_id = $edit->id;

    note('editor2 votes Yes');
    $c->model('Vote')->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_YES }],
    );

    note('editor3 enters a note');
    $c->model('EditNote')->add_note(
        $edit_id,
        { text => 'This is my note!', editor_id => 3 },
    );

    $c->model('EditNote')->load_for_edits($edit);
    is(@{ $edit->edit_notes }, 1, 'Edit has one edit note');
    check_note(
        $edit->edit_notes->[0],
        'MusicBrainz::Server::Entity::EditNote',
        (
            editor_id => 3,
            edit_id => 3,
            text => 'This is my note!',
        ),
    );

    my $server = 'https://' . DBDefs->WEB_SERVER_USED_IN_EMAIL;
    my $email_transport = MusicBrainz::Server::Email->get_test_transport;
    is($email_transport->delivery_count, 2, 'Exactly two emails sent');

    my $email = $email_transport->shift_deliveries->{email};
    my $email2 = $email_transport->shift_deliveries->{email};

    note('Checking email sent to editor1 (edit creator)');
    is(
        $email->get_header('Subject'),
        'Note added to your edit #' . $edit_id,
        'Subject explains a note was added to edit',
    );
    is(
        $email->get_header('To'),
        '"editor1" <editor1@example.com>',
        'Email is addressed to editor1',
    );
    my $email_body = $email->object->body_str;
    like(
        $email_body,
        qr{$server/edit/$edit_id},
        'Email body contains edit url',
    );
    like(
        $email_body,
        qr{'editor3' has added},
        'Email body mentions editor3 (note adder)',
    );
    like(
        $email_body,
        qr{to your edit #$edit_id},
        'Email body mentions "your edit #"',
    );
    like(
        $email_body,
        qr{This is my note!},
        'Email body has correct edit note text',
    );

    note('Checking email sent to editor2 (voter)');
    is(
        $email2->get_header('Subject'),
        'Note added to edit #' . $edit_id,
        'Subject explains a note was added to edit',
    );
    is(
        $email2->get_header('To'),
        '"editor2" <editor2@example.com>',
        'Email is addressed to editor2',
    );
    my $email2_body = $email2->object->body_str;
    like(
        $email2_body,
        qr{$server/edit/$edit_id},
        'Email body contains edit url',
    );
    like(
        $email2_body,
        qr{'editor3' has added},
        'Email body mentions editor3 (note adder)',
    );
    like(
        $email2_body,
        qr{to edit #$edit_id},
        'Email body mentions "edit #" (not "your edit")',
    );
    like(
        $email2_body,
        qr{This is my note!},
        'Email body has correct edit note text',
    );

    note('We set no emails on votes for editor2 and on notes for editor3');
    $test->c->sql->do(<<~'SQL');
        INSERT INTO editor_preference (editor, name, value)
             VALUES (3, 'email_on_notes', '0'),
                    (2, 'email_on_vote', '0')
        SQL

    note('editor1 (edit creator) enters a note');
    $c->model('EditNote')->add_note(
        $edit_id,
        { text => 'This is my response!', editor_id => 1 },
    );

    $email_transport = MusicBrainz::Server::Email->get_test_transport;
    is(
        $email_transport->delivery_count,
        0,
        'No emails were sent because of voter and note adder preferences',
    );

    note('We set no emails on votes or notes preference for editor1');
    $test->c->sql->do(<<~'SQL');
        INSERT INTO editor_preference (editor, name, value)
             VALUES (1, 'email_on_notes', '0'),
                    (1, 'email_on_vote', '0')
        SQL

    note('editor3 enters another note');
    $c->model('EditNote')->add_note(
        $edit_id,
        { text => 'This is my new note!', editor_id => 3 },
    );

    $email_transport = MusicBrainz::Server::Email->get_test_transport;
    is($email_transport->delivery_count, 1, 'One email was sent');
    $email = $email_transport->shift_deliveries->{email};
    is(
        $email->get_header('To'),
        '"editor1" <editor1@example.com>',
        'Email was sent to edit creator editor1, despite their preferences',
    );

    note('We set emails on votes, but not abstain votes, for editor2');
    $test->c->sql->do(<<~'SQL');
        UPDATE editor_preference
           SET value = 1
         WHERE name = 'email_on_vote'
           AND editor = 2
        SQL
    $test->c->sql->do(<<~'SQL');
        INSERT INTO editor_preference (editor, name, value)
             VALUES (2, 'email_on_abstain', '0')
        SQL

    note('editor1 (edit creator) enters another note');
    $c->model('EditNote')->add_note(
        $edit_id,
        { text => 'This is my second response!', editor_id => 1 },
    );

    $email_transport = MusicBrainz::Server::Email->get_test_transport;
    is($email_transport->delivery_count, 1, 'One email was sent');
    $email = $email_transport->shift_deliveries->{email};
    is(
        $email->get_header('To'),
        '"editor2" <editor2@example.com>',
        'Email was sent to voter editor2',
    );

    note('editor2 changes their vote to Abstain');
    $c->model('Vote')->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_ABSTAIN }],
    );

    note('editor1 (edit creator) enters a third note');
    $c->model('EditNote')->add_note(
        $edit_id,
        { text => 'This is my third response!', editor_id => 1 },
    );

    $email_transport = MusicBrainz::Server::Email->get_test_transport;
    is(
        $email_transport->delivery_count,
        0,
        'No emails were sent because of the abstain note preferences',
    );
};

test 'Adding notes is allowed / blocked in the appropriate cases' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_note');

    my $edit = $c->model('Edit')->get_by_id(3);
    my $edit_id = $edit->id;

    my $edit_creator = $c->model('Editor')->get_by_id(1);
    my $unverified = $c->model('Editor')->get_by_id(5);
    my $beginner = $c->model('Editor')->get_by_id(6);

    note('We try to enter a note with the editor who entered the edit');
    $c->model('EditNote')->add_note(
        $edit_id,
        { text => 'This is my note!', editor_id => $edit_creator->id },
    );

    $edit = $c->model('Edit')->get_by_id($edit_id);
    $c->model('EditNote')->load_for_edits($edit);
    is(@{ $edit->edit_notes }, 1, 'An edit note was added');

    note('We try to enter a note with a beginner editor');
    $c->model('EditNote')->add_note(
        $edit_id,
        { text => 'This is my note!', editor_id => $beginner->id },
    );

    $edit = $c->model('Edit')->get_by_id($edit_id);
    $c->model('EditNote')->load_for_edits($edit);
    is(@{ $edit->edit_notes }, 2, 'An edit note was added');

    note('We try to enter a note with an unverified editor');
    ok exception {
        $c->model('EditNote')->add_note(
            $edit_id,
            { text => 'This is my note!', editor_id => $unverified->id },
        );
    }, 'We got an exception';
    $edit = $c->model('Edit')->get_by_id($edit_id);
    $c->model('EditNote')->load_for_edits($edit);
    is(@{ $edit->edit_notes }, 2, 'No note was added');
};

test 'Can add edit notes in transaction' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+edit_note');

    my $edit = $c->model('Edit')->get_by_id(3);

    $c->sql->begin;
    lives_ok (
        sub {
            $c->model('EditNote')->insert(
                $edit->id,
                { editor_id => 3, text => 'Note' },
            );
        },
        'Edit notes don’t die while in a transaction already',
    );
    $c->sql->commit;
};

test 'delete_content' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+edit_note');

    note('We remove the first edit note for edit #1');
    $c->model('EditNote')->delete_content(1, 1, 'Wrong URL');

    my $edit = $c->model('Edit')->get_by_id(1);
    $c->model('EditNote')->load_for_edits($edit);

    is(@{ $edit->edit_notes }, 2, 'The edit still has two edit notes');
    is(
        $edit->edit_notes->[0]->text,
        '',
        'The note text for the first note has been blanked',
    );
    is(
        $edit->edit_notes->[1]->text,
        'This is a later note',
        'The note text for the second note is unchanged',
    );

    note('Check the edit_note_change row contents');
    my $row = $c->sql->select_single_row_hash(
        'SELECT * FROM edit_note_change WHERE edit_note = 1',
    );
    is($row->{status}, 'deleted', 'The change is marked as a removal');
    is($row->{change_editor}, 1, 'The correct change editor is listed');
    is(
        $row->{old_note},
        'This is a note',
        'The old note is stored correctly',
    );
    is($row->{new_note}, '', 'The new (blanked) note is stored correctly');
    is($row->{reason}, 'Wrong URL', 'The change reason is stored correctly');
};

test 'modify_content' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+edit_note');

    note('We modify the note text for the first edit note for edit #1');
    $c->model('EditNote')->modify_content(1, 1, 'Platypus', 'Best animal');

    my $edit = $c->model('Edit')->get_by_id(1);
    $c->model('EditNote')->load_for_edits($edit);

    is(@{ $edit->edit_notes }, 2, 'The edit still has two edit notes');
    is(
        $edit->edit_notes->[0]->text,
        'Platypus',
        'The note text for the first edit note has been modified',
    );
    is(
        $edit->edit_notes->[1]->text,
        'This is a later note',
        'The note text for the second edit note has not been modified',
    );

    note('Check the edit_note_change row contents');
    my $row = $c->sql->select_single_row_hash(
        'SELECT * FROM edit_note_change WHERE edit_note = 1',
    );
    is($row->{status}, 'edited', 'The change is marked as a modification');
    is($row->{change_editor}, 1, 'The correct change editor is listed');
    is(
        $row->{old_note},
        'This is a note',
        'The old edit note is stored correctly',
    );
    is(
        $row->{new_note},
        'Platypus',
        'The new edit note is stored correctly',
    );
    is(
        $row->{reason},
        'Best animal',
        'The change reason is stored correctly',
    );
};

sub check_note {
    my ($note, $class, %attrs) = @_;
    isa_ok($note, $class);
    is($note->$_, $attrs{$_}, "check_note: $_ is ".$attrs{$_})
        for keys %attrs;
    ok(defined $note->post_time, 'check_note: edit has post time');
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
