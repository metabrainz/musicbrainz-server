package t::MusicBrainz::Server::Controller::User::Show;
use strict;
use warnings;

use Test::Routine;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get('/user/new_editor');
$mech->content_contains('Collection', 'Collection tab appears on profile of user');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'alice', password => 'secret1' } );

$mech->get('/user/alice');
$mech->content_contains('Collection', 'Collection tab appears on own profile, even if marked private');

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
