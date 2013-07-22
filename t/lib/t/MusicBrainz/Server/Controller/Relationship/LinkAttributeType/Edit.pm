package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Edit;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, privs, ha1, email_confirm_date) VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', 255, '16a4862191803cb596ee4b16802bb7ee', now())
EOSQL

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Editing a relationship attribute /relationship-attribute/edit for a valid attribute type' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $test->c->sql->do(<<'EOSQL');
INSERT INTO link_attribute_type (id, root, gid, name)
  VALUES (1, 1, '77a0f1d3-f9ec-4055-a6e7-24d7258c21f7', 'Additional');
EOSQL

    $mech->get_ok(
        '/relationship-attribute/77a0f1d3-f9ec-4055-a6e7-24d7258c21f7/edit');

    my ($new_name, $new_description) = (
        'Additional additional', 'Extra additional'
    );

    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linkattrtype.name' => $new_name,
                'linkattrtype.description' => $new_description
            }
        );
        ok($mech->success);

        my @redir = $response->redirects;
        like($redir[0]->content, qr{http://localhost/relationship-attributes\?msg=updated}, "Redirect contains link to main relationship page.");
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

    $test->c->sql->do(<<'EOSQL');
INSERT INTO link_attribute_type (id, parent, root, gid, name)
  VALUES (14, NULL, 14, '0abd7f04-5e28-425b-956f-94789d9bcbe2', 'instrument'), (1, 14, 14, 'f6100277-c7b8-4c8d-aa26-d8cd014b6761', 'trombone');
EOSQL

    $mech->get_ok(
        '/relationship-attribute/f6100277-c7b8-4c8d-aa26-d8cd014b6761/edit');

    my ($new_name, $new_description) = (
        'trombone edit', 'Trombone, now with edits'
    );

    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linkattrtype.name' => $new_name,
                'linkattrtype.description' => $new_description
            }
        );
        ok($mech->success);

        my @redir = $response->redirects;
        like($redir[0]->content, qr{http://localhost/relationship-attributes/instruments\?msg=updated}, "Redirect contains link to instrument tree page.");
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::EditLinkAttribute');
    is($edits[0]->data->{entity_id}, 1, 'Edits relationship attribute 1');
    is($edits[0]->data->{new}{name}, $new_name, "Sets the new name to $new_name");
    is($edits[0]->data->{new}{description}, $new_description,
       "Sets the new description to $new_description");
};

test 'GET /relationship/attribute/edit for invalid attribute types' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get(
        '/relationship-attribute/77a0f1d3-beee-4055-a6e7-24d7258c21f7/edit/');

    is($mech->status, 404,
       'Returns 404 when trying to edit a non-existant relationship attribute');
};

1;
