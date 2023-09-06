package t::MusicBrainz::Server::Controller::User::Show;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test 'Private tabs only appear where allowed' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/user/new_editor');
    $mech->content_contains(
        '/user/new_editor/tags">Tags',
        'Tags tab appears on profile of user when viewing logged out',
    );

    $mech->get('/user/Alice');
    $mech->content_lacks(
        '/user/Alice/tags">Tags',
        'Tags tab does not appear when logged out if tag data marked private',
    );

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'kuno', password => 'byld' },
    );

    $mech->get('/user/new_editor');
    $mech->content_contains(
        '/user/new_editor/tags">Tags',
        'Tags tab appears on profile of user when viewing logged in',
    );

    $mech->get('/user/Alice');
    $mech->content_lacks(
        '/user/Alice/tags">Tags',
        'Tags tab does not appear when logged in if tag data marked private',
    );

    $mech->get('/logout');
    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'Alice', password => 'secret1' },
    );

    $mech->get('/user/Alice');
    $mech->content_contains(
        '/user/Alice/tags">Tags',
        'Tags tab appears on own profile, even if marked private',
    );
};

test 'User restrictions display' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'kuno', password => 'byld' },
    );

    $mech->get('/user/Alice');
    $mech->text_lacks(
        'Restrictions',
        'No restriction info shown if none applies',
    );

    note('We remove the editor’s edit note privileges and set Untrusted');
    $test->c->sql->do(<<~'SQL');
        UPDATE editor
           SET privs = 4+2048
         WHERE name = 'Alice'
        SQL

    $mech->get('/user/Alice');
    $mech->text_contains(
        'Restrictions:Edit notes disabled',
        'Restriction info shown when logged in as other (but not Untrusted)',
    );

    $mech->get('/logout');

    $mech->get('/user/Alice');
    $mech->text_lacks(
        'Restrictions',
        'No restriction info shown when logged out',
    );

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'Alice', password => 'secret1' },
    );

    $mech->get('/user/Alice');
    $mech->text_contains(
        'Restrictions:Edit notes disabled',
        'Restriction info shown when logged in as self (but not Untrusted)',
    );

    $test->c->sql->do(<<~'SQL');
        UPDATE editor
           SET privs = 128
         WHERE name = 'kuno'
        SQL

    $mech->get('/logout');
    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'kuno', password => 'byld' },
    );

    $mech->get('/user/Alice');
    $mech->text_contains(
        'Restrictions:Edit notes disabled, Untrusted',
        'Restriction info including Untrusted shown when logged in as admin',
    );
};

test 'Spammer editors are hidden, except for admins' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    # Add our spam editor
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
      INSERT INTO editor (
                      id, name, password,
                      privs, email, website, bio,
                      member_since, email_confirm_date, last_login_date,
                      ha1
                  )
           VALUES (
                      5, 'SPAMVIKING', '{CLEARTEXT}SpamBaconSausageSpam',
                      4096, 'spam@bromleycafe.com', '', 'spammy spam',
                      '2010-03-25', '2010-03-25', now(),
                      '1e30903480b84af674780f41ac54dfec'
                  )
      SQL

    # Make kuno an account admin
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        UPDATE editor SET privs = 128 WHERE id = 3;
        SQL

    $mech->get_ok('/user/SPAMVIKING', 'Fetched spammer page while logged out');
    $mech->content_contains(
        'Blocked Spam Account',
        'Spammer user page is blocked for logged out users',
    );
    $mech->content_lacks(
        'spammy spam',
        'Spammer user bio is not visible for logged out users',
    );

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'alice', password => 'secret1' }
    );

    $mech->get_ok('/user/SPAMVIKING', 'Fetched spammer page as normal user');
    $mech->content_contains(
        'Blocked Spam Account',
        'Spammer user page is blocked for normal users',
    );
    $mech->content_lacks(
        'spammy spam',
        'Spammer user bio is not visible for normal users',
    );

    $mech->get('/logout');
    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'kuno', password => 'byld' }
    );

    $mech->get_ok('/user/SPAMVIKING', 'Fetched spammer page as admin');
    $mech->content_contains(
        'This user is marked as a spammer',
        'Spammer user warning is shown to admin',
    );
    $mech->content_contains(
        'spammy spam',
        'Spammer user bio is visible for admins',
    );
};

1;
