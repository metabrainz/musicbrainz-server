package t::MusicBrainz::Server::Controller::Collection::Move;
use Test::Routine;
use Test::More;
use Test::XPath;
use MusicBrainz::Server::Test qw( html_ok );
use HTTP::Status qw( :constants );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+collection');

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'If you only have 1 collection then there is no move option' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cd');
    my $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );
    $tx->is('count(//div[@id="content"]/form/span)', "1", 'only one span (delete releases button)');
};

test 'More than 1 collection, option to move' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'editor2', password => 'pass' } );

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    my $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );

    $tx->is('count(//div[@id="content"]/form/span)', "3", '3 spans (delete, move to, move)');
    $tx->is('count(//div[@id="content"]/form/span/select/option)', "2", '2 options (-- and actual collection)');
    $tx->is('count(//table[@class="tbl"]/tbody/tr)', "2", "2 releases in the table");

    $mech->form_number(2);
    $mech->select("move_releases_to", "collection3");
    $mech->tick("remove", "4");
    $mech->click_button( value => 'Move');

    $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );
    $tx->is('count(//table[@class="tbl"]/tbody/tr)', "1", "one release in the table");

    # Other collection
    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );
    $tx->is('count(//table[@class="tbl"]/tbody/tr)', "1", "one release in the table");

};

1;
