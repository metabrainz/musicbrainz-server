package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Index;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok test_xpath_html );

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

test 'GET /relationship-attributes as admin' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $test->c->sql->do(<<'EOSQL');
INSERT INTO link_attribute_type (id, root, gid, name)
  VALUES (1, 1, '77a0f1d3-f9ec-4055-a6e7-24d7258c21f7', 'Additional');
EOSQL

    $mech->get_ok('/relationship-attributes');
    my $tx = test_xpath_html ($mech->content);
    $tx->ok('//html:a[contains(@href,"/relationship-attribute/77a0f1d3-f9ec-4055-a6e7-24d7258c21f7/edit")]',
            'has a link to edit the attribute');
    $tx->ok('//html:a[contains(@href,"/relationship-attribute/77a0f1d3-f9ec-4055-a6e7-24d7258c21f7/delete")]',
            'has a link to delete the attribute');
    $tx->ok('//html:a[contains(@href,"/relationship-attributes/create")]',
            'has a link to create new attributes');
};

1;
