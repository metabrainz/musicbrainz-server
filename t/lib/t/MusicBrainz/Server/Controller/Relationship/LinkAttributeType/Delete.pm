package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Delete;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, email, privs, ha1, email_confirm_date)
            VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', 255, '16a4862191803cb596ee4b16802bb7ee', now())
        SQL

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Deleting relationship attributes' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok(
        '/relationship-attribute/0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f/delete');
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->form_with_fields('confirm.submit');
        $mech->click('confirm.submit');
        ok($mech->success);

        is($mech->uri, 'http://localhost/relationship-attributes', 'Redirect contains link to main relationship page.');
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::RemoveLinkAttribute');
    is($edits[0]->data->{id}, 1, 'Edits relationship attribute 1');
};

test 'Deleting relationship attributes (instrument)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get(
        '/relationship-attribute/f6100277-c7b8-4c8d-aa26-d8cd014b6761/delete');
    is($mech->status, 403);
};
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
