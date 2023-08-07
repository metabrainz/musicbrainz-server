package t::MusicBrainz::Server::Controller::EditNote::NoteHistory;
use strict;
use warnings;

use DateTime;
use Test::Routine;
use Test::More;
use utf8;

use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Context', 't::Mechanize';

=head1 DESCRIPTION

This checks that edit note history pages are shown correctly,
and that they can be viewed by admins and only by admins.

=cut

test 'History page links' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+edit_note_history',
    );

    # Test as normal editor
    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => {username => 'editor1', password => 'pass'}
    );

    note('We get the edit with modified notes as a normal editor');
    $mech->get_ok('/edit/1');
    html_ok($mech->content);

    my @history_link_matches = $mech->content =~ /see all changes/g;
    is(
        scalar @history_link_matches,
        0,
        'No history page links are shown to normal editor',
    );

    $mech->get('/logout');

    # Test as admin
    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => {username => 'admin3', password => 'pass'}
    );

    note('We get the edit with modified notes as an admin');
    $mech->get_ok('/edit/1');
    html_ok($mech->content);

    @history_link_matches = $mech->content =~ /see all changes/g;
    is(
        scalar @history_link_matches,
        2,
        '2 history page links are shown to admin (one per note with changes)',
    );
};

test 'History page display' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+edit_note_history',
    );

    # Test as admin
    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => {username => 'admin3', password => 'pass'}
    );

    note('We get the history for a note with two modifications');
    $mech->get_ok('/edit-note/1/changes');
    html_ok($mech->content);

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the changes table',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[3]',
        '2014-12-07 00:00 UTC',
        'The latest change is shown first',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'editor1',
        'The latest change is by editor1',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[2]',
        'edited',
        'The latest change is a modification',
    );
    $tx->like(
        '//table[@class="tbl"]/tbody/tr[1]/td[4]',
        qr/no reason specified/,
        'The latest change has no reason given',
    );

    $tx->is(
        '//table[@class="tbl"]/tbody/tr[2]/td[3]',
        '2014-12-06 00:00 UTC',
        'The oldest change is shown last',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[2]/td[1]',
        'editor1',
        'The oldest change is by editor1',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[2]/td[2]',
        'edited',
        'The oldest change is a modification',
    );
    $tx->like(
        '//table[@class="tbl"]/tbody/tr[2]/td[4]',
        qr/typo/,
        'The oldest change reason is listed',
    );

    note('We get the history for a note with no changes');
    $mech->get_ok('/edit-note/2/changes');
    html_ok($mech->content);

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '0',
        'There are no entries in the changes table',
    );

    note('We get the history for a note with one deletion');
    $mech->get_ok('/edit-note/3/changes');
    html_ok($mech->content);

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the changes table',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[3]',
        '2016-12-05 00:00 UTC',
        'The date is correct',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'admin3',
        'The change is by admin3',
    );
        $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[2]',
        'deleted',
        'The latest change is a removal',
    );
    $tx->like(
        '//table[@class="tbl"]/tbody/tr[1]/td[4]',
        qr/Unhelpful/,
        'The change reason is listed',
    );
};

test 'Change page display' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+edit_note_history',
    );

    # Test as admin
    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => {username => 'admin3', password => 'pass'}
    );

    note('We get the first change in the first note');
    $mech->get_ok('/edit-note/1/change/1');
    html_ok($mech->content);
    $mech->text_contains(
        'edited',
        'The change status is present',
    );
    $mech->text_contains(
        'editor1',
        'The changing editor is present',
    );
    $mech->text_contains(
        'This is a messy ntoe',
        'The old note content is present',
    );
    $mech->text_contains(
        'This is a messy note',
        'The new note content is present',
    );
    $mech->text_contains(
        'typo',
        'The change reason is present',
    );

    note('We get the second change in the first note');
    $mech->get_ok('/edit-note/1/change/2');
    html_ok($mech->content);
    $mech->text_contains(
        'edited',
        'The change status is present',
    );
    $mech->text_contains(
        'editor1',
        'The changing editor is present',
    );
    $mech->text_contains(
        'This is a messy note',
        'The old note content is present',
    );
    $mech->text_contains(
        'This is a fixed note',
        'The new note content is present',
    );
    $mech->text_contains(
        'No reason entered',
        'The "No reason entered" message is present',
    );

    note('We try to get the third change from the first note');
    $mech->get('/edit-note/1/change/3');
    is(
        $mech->status,
        400,
        'Trying to get a change from the wrong note gives a 400 Bad Request error',
    );
    $mech->text_contains(
        'is not associated with this note',
        'The error message saying this is the wrong note is displayed',
    );

    note('We get the only change in the third note');
    $mech->get_ok('/edit-note/3/change/3');
    html_ok($mech->content);
    $mech->text_contains(
        'Typedeleted', # To test it ignoring "was deleted" below
        'The change status is present',
    );
    $mech->text_contains(
        'Changing editoradmin3', # To test it ignoring the header link
        'The changing editor is present',
    );
    $mech->text_contains(
        'I HATE YOU ALL',
        'The old note content is present',
    );
    $mech->text_contains(
        'This note was deleted',
        'The deleted note message is present',
    );
    $mech->text_contains(
        'Unhelpful',
        'The change reason is present',
    );
};

test 'Pages are blocked for non-admins' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+edit_note_history',
    );

    $mech->get('/edit-note/1/changes');
    $mech->text_contains(
        'You need to be logged in to view this page',
        'Trying to view the history page requires login',
    );

    $mech->get('/edit-note/1/change/1');
    $mech->text_contains(
        'You need to be logged in to view this page',
        'Trying to view a specific change page requires login',
    );

    # Test as normal editor
    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => {username => 'editor1', password => 'pass'}
    );

    $mech->get('/edit-note/1/changes');
    is(
        $mech->status,
        403,
        'Trying to get the history page as a non-admin gives a 403 Forbidden error',
    );

    $mech->get('/edit-note/1/change/1');
    is(
        $mech->status,
        403,
        'Trying to get a specific change page as a non-admin gives a 403 Forbidden error',
    );
};

1;
