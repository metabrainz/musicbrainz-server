package t::MusicBrainz::Server::Controller::Admin::DeleteEditor;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether admins can delete an editor account, and whether
the editors themselves can do it. It also checks whether users are logged out
(or not) appropriately.

=cut

test 'Delete account as a regular user' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $second_session = $test->make_mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'Alice', password => 'secret1' } );

    $second_session->get('/account/edit');
    $second_session->content_contains(
        'You need to be logged in to view this page',
        'Not logged in in second session',
    );
    $second_session->get('/login');
    $second_session->submit_form( with_fields => { username => 'Alice', password => 'secret1' } );

    $mech->get('/');
    $mech->content_contains('Alice', 'Regular user "Alice" is logged in');

    $second_session->get('/');
    $second_session->content_contains(
        'Alice',
        'User "Alice" is logged in in second session',
    );

    $mech->get('/admin/user/delete/new_editor');
    is($mech->status(), 403, 'Regular user cannot delete other accounts');

    $mech->get_ok(
        '/admin/user/delete/Alice',
        'Regular user can access their own deletion page',
    );
    html_ok($mech->content);
    $mech->submit_form( form_id => 'delete-account-form' );

    is(
        $mech->uri->path,
        '/user/Deleted%20Editor%20%232',
        q(Redirected to the deleted editor's profile),
    );
    $mech->content_contains('Log In', 'The editor is no longer logged in');

    $mech->get_ok('/account/edit');
    html_ok($mech->content);
    $mech->content_contains(
        'You need to be logged in to view this page',
        'The editor cannot access the account edit page anymore',
    );

    $second_session->get('/');
    is(
        $second_session->status,
        500,
        'Restoring the deleted user in the second session fails',
    );

    $second_session->get_ok('/');
    $second_session->content_contains(
        'Log In',
        'The deleted user is no longer logged in from the second session',
    );
};

test 'Delete account as an admin' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    # Make kuno an account admin
    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        'UPDATE editor SET privs = 128 WHERE id = 3',
    );

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'kuno', password => 'byld' } );

    $mech->get('/');
    $mech->content_contains('kuno', 'Admin user "kuno" is logged in');

    $mech->get_ok(
        '/admin/user/delete/Alice',
        q(Admin can access other editor's account deletion page),
    );
    html_ok($mech->content);
    $mech->submit_form( form_id => 'delete-account-form' );

    is(
        $mech->uri->path,
        '/user/Deleted%20Editor%20%232',
        q(Redirected to the deleted editor's profile),
    );
    $mech->content_contains('kuno', 'Admin user "kuno" is still logged in');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
