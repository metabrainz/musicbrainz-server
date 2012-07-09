package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Delete;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

use HTTP::Request::Common qw( POST );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, privs)
  VALUES (1, 'editor1', 'pass', 'editor1@example.com', 255)
EOSQL

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Deleting relationship attributes' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $test->c->sql->do(<<'EOSQL');
INSERT INTO link_attribute_type (id, root, gid, name)
  VALUES (1, 1, '77a0f1d3-f9ec-4055-a6e7-24d7258c21f7', 'Additional');
EOSQL

    $mech->get_ok(
        '/relationship-attribute/77a0f1d3-f9ec-4055-a6e7-24d7258c21f7/delete');

    my @edits = capture_edits {
        my $response = $mech->request(
            POST $mech->uri, [ 'confirm.submit' => 1 ]
        );
        ok($mech->success);
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::RemoveLinkAttribute');
    is($edits[0]->data->{id}, 1, 'Edits relationship attribute 1');
};

1;
