package t::MusicBrainz::Server::Controller::Relationship::LinkAttributeType::Index;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

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

test 'GET /relationship-attributes as admin' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/relationship-attributes');
    html_ok($mech->content);
    my $tx = test_xpath_html($mech->content);
    $tx->ok('//a[contains(@href,"/relationship-attribute/0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f/edit")]',
            'has a link to edit the attribute');
    $tx->ok('//a[contains(@href,"/relationship-attribute/0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f/delete")]',
            'has a link to delete the attribute');
    $tx->ok('//a[contains(@href,"/relationship-attributes/create")]',
            'has a link to create new attributes');
};

1;
