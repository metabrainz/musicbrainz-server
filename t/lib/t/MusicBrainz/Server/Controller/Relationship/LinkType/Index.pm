package t::MusicBrainz::Server::Controller::Relationship::LinkType::Index;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, privs, ha1) VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', 255, '16a4862191803cb596ee4b16802bb7ee')
EOSQL

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Viewing /relationship/artist-artist as admin' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $test->c->sql->do(<<'EOSQL');
INSERT INTO link_type (id, gid, entity_type0, entity_type1, name,
    link_phrase, reverse_link_phrase, long_link_phrase)
  VALUES (1, '77a0f1d3-f9ec-4055-a6e7-24d7258c21f7', 'artist', 'artist', 'member of band', '', '', '');
EOSQL

    $mech->get_ok('/relationships/artist-artist');
    my $tx = test_xpath_html ($mech->content);

    $tx->ok('//html:a[contains(@href,"/relationship/77a0f1d3-f9ec-4055-a6e7-24d7258c21f7/edit")]',
            'has a link to edit the relationship type');
    $tx->ok('//html:a[contains(@href,"/relationship/77a0f1d3-f9ec-4055-a6e7-24d7258c21f7/delete")]',
            'has a link to delete the relationship type');
    $tx->ok('//html:a[contains(@href,"/relationships/artist-artist/create")]',
            'has a link to create new relationship types');
};

test 'Viewing /relationships shows a full tree' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/relationships');
    my $tx = test_xpath_html ($mech->content);

    $tx->ok('//html:a[contains(@href,"/relationships/artist-artist")]',
            'has a link to artist-artist relationships');
    $tx->ok('//html:a[contains(@href,"/relationships/work-work")]',
            'has a link to work-work relationships');
};

test 'Cannot view impossible relationships' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/relationships/fake-fake');
    is($mech->status, 400);
};

1;
