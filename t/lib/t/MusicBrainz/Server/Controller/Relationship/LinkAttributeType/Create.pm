package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Create;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, privs)
  VALUES (1, 'editor1', 'pass', 'editor1@example.com', 255)
EOSQL

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor1', password => 'pass' }
    );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Creating a relationship attribute' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/relationship-attributes/create');

    my ($new_name, $new_child_order) = ('New Attribute', 1);
    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linkattrtype.child_order' => $new_child_order,
                'linkattrtype.name' => $new_name
            }
        );
        ok($mech->success);
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::AddLinkAttribute');
    is($edits[0]->data->{name}, $new_name, "Sets the new name to $new_name");
    is($edits[0]->data->{child_order}, $new_child_order,
       "Sets the child order to $new_child_order");
};

1;
