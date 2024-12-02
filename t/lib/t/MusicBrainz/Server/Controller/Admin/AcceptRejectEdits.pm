package t::MusicBrainz::Server::Controller::Admin::AcceptRejectEdits;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Constants qw(
    :edit_status
    :vote
    $EDIT_ARTIST_EDIT
    $UNTRUSTED_FLAG
);

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether admins can accept and reject any edits, and ensures
non-admins are not able to do so.

=cut

test 'Try to accept/reject edit as a regular user' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => {
        username => 'editor1',
        password => 'pass',
    } );

    $mech->get('/');
    $mech->content_contains('editor1', 'Non-admin user "editor1" is logged in');

    $mech->get(
        '/admin/accept-edit/' . $edit->id,
        q(Try to access the accept edit endpoint as a non-admin),
    );
    is($mech->status, HTTP_FORBIDDEN,
        'The attempt to access the endpoint was rejected');

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $test->c->model('Vote')->load_for_edits($edit);
    is($edit->status, $STATUS_OPEN, 'The edit is still open');
    is(scalar @{ $edit->votes }, 0, 'The vote count is still 0');

    $mech->get(
        '/admin/reject-edit/' . $edit->id,
        q(Try to access the reject edit endpoint as a non-admin),
    );
    is($mech->status, HTTP_FORBIDDEN,
        'The attempt to access the endpoint was rejected');

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $test->c->model('Vote')->load_for_edits($edit);
    is($edit->status, $STATUS_OPEN, 'The edit is still open');
    is(scalar @{ $edit->votes }, 0, 'The vote count is still 0');
};

test 'Try to accept an edit as an admin' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => {
        username => 'editor7',
        password => 'pass',
    } );

    $mech->get('/');
    $mech->content_contains('editor7', 'Admin user "editor7" is logged in');

    $mech->get_ok(
        '/admin/accept-edit/' . $edit->id,
        q(Admin can access the accept edit endpoint for other's edits),
    );

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    is($edit->status, $STATUS_APPLIED, 'applied');
    $test->c->model('Vote')->load_for_edits($edit);
    is($edit->votes->[0]->vote, $VOTE_ADMIN_APPROVE, 'Vote is Admin approval');
    is($edit->votes->[0]->editor_id, 7, 'Vote is by editor7');
};

test 'Try to reject an edit as an admin' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => {
        username => 'editor7',
        password => 'pass',
    } );

    $mech->get('/');
    $mech->content_contains('editor7', 'Admin user "editor7" is logged in');

    $mech->get_ok(
        '/admin/reject-edit/' . $edit->id,
        q(Admin can access the reject edit endpoint for other's edits),
    );

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    is($edit->status, $STATUS_FAILEDVOTE, 'Rejected with Failed vote');
    $test->c->model('Vote')->load_for_edits($edit);
    is($edit->votes->[0]->vote, $VOTE_ADMIN_REJECT, 'Vote is Admin rejection');
    is($edit->votes->[0]->editor_id, 7, 'Vote is by editor7');
};

test 'Try to accept own edit as an admin' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test, 7);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => {
        username => 'editor7',
        password => 'pass',
    } );

    $mech->get('/');
    $mech->content_contains('editor7', 'Admin user "editor7" is logged in');

    $mech->get_ok(
        '/admin/accept-edit/' . $edit->id,
        q(Admin can access the accept edit endpoint for own edits),
    );

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    is($edit->status, $STATUS_APPLIED, 'applied');
    $test->c->model('Vote')->load_for_edits($edit);
    is($edit->votes->[0]->vote, $VOTE_ADMIN_APPROVE, 'Vote is Admin approval');
    is($edit->votes->[0]->editor_id, 7, 'Vote is by editor7');
};

test 'Try to reject own edit as an admin' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $edit = prepare($test, 7);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => {
        username => 'editor7',
        password => 'pass',
    } );

    $mech->get('/');
    $mech->content_contains('editor7', 'Admin user "editor7" is logged in');

    $mech->get_ok(
        '/admin/reject-edit/' . $edit->id,
        q(Admin can access the reject edit endpoint for own edits),
    );

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    is($edit->status, $STATUS_FAILEDVOTE, 'Rejected with Failed vote');
    $test->c->model('Vote')->load_for_edits($edit);
    is($edit->votes->[0]->vote, $VOTE_ADMIN_REJECT, 'Vote is Admin rejection');
    is($edit->votes->[0]->editor_id, 7, 'Vote is by editor7');
};

sub prepare {
    my ($test, $editor_id) = @_;

    local *DBDefs::DB_STAGING_TESTING_FEATURES = sub { 0 };
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');

    my $edit = $test->c->model('Edit')->create(
        editor_id => $editor_id // 1,
        edit_type => $EDIT_ARTIST_EDIT,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'Changed comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    return $edit;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
