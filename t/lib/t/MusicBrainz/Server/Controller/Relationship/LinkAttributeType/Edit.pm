package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Edit;
use strict;
use warnings;

use HTTP::Status qw( :constants );
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

test 'Editing a relationship attribute /relationship-attribute/edit for a valid attribute type' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok(
        '/relationship-attribute/0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f/edit');
    html_ok($mech->content);

    my ($new_name, $new_description) = (
        'Additional additional', 'Extra additional',
    );

    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linkattrtype.name' => $new_name,
                'linkattrtype.description' => $new_description,
            },
        );
        ok($mech->success);

        my @redir = $response->redirects;
        like($redir[0]->content, qr{http://localhost/relationship-attribute/0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f}, 'Redirect contains link to attribute type page.');
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::EditLinkAttribute');
    is($edits[0]->data->{entity_id}, 1, 'Edits relationship attribute 1');
    is($edits[0]->data->{new}{name}, $new_name, "Sets the new name to $new_name");
    is($edits[0]->data->{new}{description}, $new_description,
       "Sets the new description to $new_description");
};

test 'Editing a relationship attribute /relationship-attribute/edit for a valid instrument' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get(
        '/relationship-attribute/f6100277-c7b8-4c8d-aa26-d8cd014b6761/edit');
    is($mech->status, HTTP_FORBIDDEN);
};

test 'GET /relationship/attribute/edit for invalid attribute types' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get(
        '/relationship-attribute/77a0f1d3-beee-4055-a6e7-24d7258c21f7/edit');

    is($mech->status, HTTP_NOT_FOUND,
       'Returns 404 when trying to edit a non-existent relationship attribute');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
