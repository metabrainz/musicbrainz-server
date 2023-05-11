package t::MusicBrainz::Server::Controller::Edit::ChangeNote;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use utf8;

use MusicBrainz::Server::Test qw( html_ok );

with 't::Context', 't::Mechanize';

=head1 DESCRIPTION

This checks that edit notes can be deleted and modified, and the restrictions
on who and when can do so.

=cut

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $change_note_classname = 'change-note-controls';

    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+change_edit_note',
    );

    # Test as normal editor
    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => {username => 'editor1', password => 'pass'}
    );

    $mech->get_ok('/edit/1');
    html_ok($mech->content);
    $mech->content_contains(
        'Editor 1 leaves an extra comment',
        'Edit note is present',
    );

    # We only expect 2 edits to be changeable by editor 1
    my @change_class_matches = $mech->content =~ /$change_note_classname/g;
    is(
        scalar @change_class_matches,
        2,
        '2 sets of change edit note controls shown to normal user',
    );

    # We test this with /delete but the code for rejection is the same for /modify
    $mech->get_ok('/edit-note/1/delete');
    html_ok($mech->content);
    $mech->content_contains(
        'since somebody else has already replied',
        'Can’t remove note with replies',
    );

    $mech->get_ok('/edit-note/2/delete');
    html_ok($mech->content);
    $mech->content_contains(
        'can’t change other users',
        'Can’t remove note by other user',
    );

    $mech->get_ok('/edit-note/3/delete');
    html_ok($mech->content);
    $mech->content_contains(
        'it was entered too long ago',
        'Can’t remove too old note',
    );

    $mech->get_ok('/edit-note/4/modify');
    html_ok($mech->content);
    $mech->content_contains(
        'You are modifying the following edit note',
        'Can modify note followed by own + ModBot notes only',
    );

    note('We remove the editor’s edit note privileges');
    $test->c->sql->do(<<~'SQL');
        UPDATE editor
           SET privs = 2048
         WHERE id = 1
        SQL

    $mech->get_ok('/edit-note/4/modify');
    html_ok($mech->content);
    $mech->content_contains(
        'currently not allowed to leave or change edit notes',
        'Can’t modify same note when edit note privileges are off',
    );

    note('We restore the editor’s edit note privileges');
    $test->c->sql->do(<<~'SQL');
        UPDATE editor
           SET privs = 0
         WHERE id = 1
        SQL

    $mech->get_ok('/edit-note/4/modify');
    html_ok($mech->content);
    $mech->content_contains(
        'You are modifying the following edit note',
        'Can modify note again after recovering edit note privileges',
    );

    # Actually modify edit note 4
    $mech->submit_form(
        with_fields => {
        'edit-note-modify.text' => 'Editor 1 leaves another note years later',
        'edit-note-modify.reason' => 'Fixing typo',
        }
    );

    $mech->get_ok('/edit/1');
    html_ok($mech->content);
    $mech->content_contains(
        'Editor 1 leaves another note years later',
        'Corrected edit note is present',
    );
    $mech->content_contains(
        'Last modified by the note author',
        'Modification message is present',
    );
    $mech->content_contains(
        'Fixing typo',
        'Modification reason is present',
    );

    $mech->get_ok('/edit-note/5/delete');
    html_ok($mech->content);
    $mech->content_contains(
        'Are you sure you want to remove the following edit note',
        'Can remove last note',
    );

    # Actually remove edit note 5
    $mech->submit_form(
        with_fields => {'edit-note-delete.reason' => 'I did a dumb'}
    );

    $mech->get_ok('/edit/1');
    html_ok($mech->content);
    $mech->content_contains(
        'This edit note was removed by its author. Reason given: “I did a dumb”.',
        'Removal message (with reason) is present',
    );
    $mech->content_lacks(
        'Editor 1 leaves an extra comment',
        'Edit note is no longer present',
    );

    $mech->get_ok('/edit-note/5/delete');
    html_ok($mech->content);
    $mech->content_contains(
        'This note has already been removed',
        'Can’t remove already removed note',
    );

    $mech->get_ok('/edit-note/5/modify');
    html_ok($mech->content);
    $mech->content_contains(
        'This note has already been removed',
        'Can’t modify already removed note',
    );

    $mech->get_ok('/edit/1');
    @change_class_matches = $mech->content =~ /$change_note_classname/g;
    is(
        scalar @change_class_matches,
        1,
        'Only 1 set of change edit note controls shown to normal user after removing one note',
    );

    $mech->get('/logout');

    # Test as admin
    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => {username => 'admin3', password => 'pass'}
    );

    $mech->get_ok('/edit/1');
    @change_class_matches = $mech->content =~ /$change_note_classname/g;
    is(
        scalar @change_class_matches,
        6,
        '6 sets of change edit note controls shown to admin',
    );

    $mech->get_ok('/edit-note/1/delete');
    html_ok($mech->content);
    $mech->content_contains(
        'Are you sure you want to remove the following edit note',
        'Admin can remove older notes',
    );
    # Delete edit note 1 without a reason
    $mech->submit_form(
        with_fields => {'edit-note-delete.reason' => ''}
    );

    $mech->get_ok('/edit/1');
    html_ok($mech->content);
    $mech->content_contains(
        'This edit note was removed by an admin. No reason was provided.',
        'Removal message (without reason) is present',
    );

    $mech->get_ok('/edit-note/5/delete');
    html_ok($mech->content);
    $mech->content_contains(
        'Are you sure you want to remove the following edit note',
        'Admin can "remove" again an already removed note to change reason',
    );
    # "Delete" edit note 5 again to change the reason
    $mech->submit_form(
        with_fields => {'edit-note-delete.reason' => 'Editor made a mistake'}
    );
    $mech->get_ok('/edit/1');
    html_ok($mech->content);
    $mech->content_contains(
        'This edit note was removed by an admin. Reason given: “Editor made a mistake”.',
        'Removal message (with new reason) is present',
    );
};

1;
