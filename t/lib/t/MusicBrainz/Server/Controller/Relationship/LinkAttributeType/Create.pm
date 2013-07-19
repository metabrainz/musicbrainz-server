package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Create;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, privs, ha1) VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', 255, '16a4862191803cb596ee4b16802bb7ee')
EOSQL

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor1', password => 'pass' }
    );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Can create new relationship attribute' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/relationship-attributes/create');

    my ($name, $child_order) = (
        'Additional additional', 1
    );

    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linkattrtype.name' => $name,
                'linkattrtype.child_order' => $child_order
            }
        );
        ok($mech->success);

        my @redir = $response->redirects;
        like($redir[0]->content, qr{http://localhost/relationship-attributes\?msg=created}, "Redirect contains link to main relationship-attributes page.");
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

    $test->c->sql->do(<<'EOSQL');
INSERT INTO link_attribute_type (id, parent, root, gid, name)
  VALUES (14, NULL, 14, '0abd7f04-5e28-425b-956f-94789d9bcbe2', 'instrument'), (1, 14, 14, 'f6100277-c7b8-4c8d-aa26-d8cd014b6761', 'trombone');
EOSQL

    $mech->get_ok('/relationship-attributes/create?parent=' . $gid);

    my $parent = $test->c->model('LinkAttributeType')->get_by_gid($gid);
    my ($parent_id, $parent_name, $name, $child_order) = (
        $parent->id, $parent->name, '77th trombone', 1
    );

    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linkattrtype.name' => $name,
                'linkattrtype.child_order' => $child_order
            }
        );
        ok($mech->success);

        my @redir = $response->redirects;
        like($redir[0]->content, qr{http://localhost/relationship-attributes/instruments\?msg=created}, "Redirect contains link to instrument tree page.");
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::AddLinkAttribute');
    is($edits[0]->data->{parent_id}, $parent_id, "Sets the parent to $parent_name");
    is($edits[0]->data->{name}, $name, "Sets the name to $name");
    is($edits[0]->data->{child_order}, $child_order,
       "Sets the child order to $child_order");
};

1;
