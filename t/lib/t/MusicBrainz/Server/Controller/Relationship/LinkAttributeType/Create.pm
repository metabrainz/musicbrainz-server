package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Create;
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
    $test->mech->submit_form(
        with_fields => { username => 'editor1', password => 'pass' },
    );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Can create new relationship attribute' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/relationship-attributes/create');
    html_ok($mech->content);

    my ($name, $child_order) = (
        'Additional additional', 1,
    );

    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linkattrtype.name' => $name,
                'linkattrtype.child_order' => $child_order,
            },
        );
        ok($mech->success);

        my @redir = $response->redirects;
        like($redir[0]->content, qr{http://localhost/relationship-attribute/}, 'Redirect contains link to attribute page.');
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::AddLinkAttribute');
    is($edits[0]->data->{name}, $name, "Sets the name to $name");
    is($edits[0]->data->{child_order}, $child_order,
       "Sets the child order to $child_order");
};

test 'Can create child relationship attribute using parentid' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $gid = 'f6100277-c7b8-4c8d-aa26-d8cd014b6761';

    $mech->get_ok('/relationship-attributes/create?parent=' . $gid);
    html_ok($mech->content);

    my $parent = $test->c->model('LinkAttributeType')->get_by_gid($gid);
    my ($parent_id, $name, $child_order) = (
        $parent->id, '77th trombone', 1,
    );

    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'linkattrtype.name' => $name,
                'linkattrtype.child_order' => $child_order,
                'linkattrtype.parent_id' => $parent_id,
            },
        );
    } $test->c;
    is(@edits, 0, 'no edits created for an instrument attempt');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
