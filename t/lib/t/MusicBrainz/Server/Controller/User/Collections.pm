package t::MusicBrainz::Server::Controller::User::Collections;
use Test::Routine;
use Test::More;
use Test::XPath;
use MusicBrainz::Server::Test qw( html_ok );
use HTTP::Status qw( :constants );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+collection');

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Viewing your own collections' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/user/editor1/collections');
    my $tx = Test::XPath->new(
        xml => $mech->content,
        xmlns => { "html" => "http://www.w3.org/1999/xhtml" });
    $tx->is('count(//html:div[@id="page"]//html:table//html:th)', 4, 'your collection list has 4 cols');

    $tx->is('//html:div[@id="page"]//html:table/html:tbody/html:tr[1]/html:td[2]', 2, 'number of collections is correct');
};

test 'No collections' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/user/editor3/collections');
    my $tx = Test::XPath->new(
        xml => $mech->content,
        xmlns => { "html" => "http://www.w3.org/1999/xhtml" });
    $tx->is('//html:div[@id="page"]/html:p', 'editor3 has no public collections.', 'editor has no collections');
};

test 'Viewing someone elses collections' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/user/editor2/collections');
    my $tx = Test::XPath->new(
        xml => $mech->content,
        xmlns => { "html" => "http://www.w3.org/1999/xhtml" });
    $tx->is('count(//html:div[@id="page"]//html:table//html:th)', 2, 'other collection list has 2 cols');
};

test 'Invalid user' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/user/notauser/collections');
    is($mech->status, HTTP_NOT_FOUND);
};

1;
