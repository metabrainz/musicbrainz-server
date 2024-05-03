package t::MusicBrainz::Server::Controller::User::Collections;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( test_xpath_html );
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
    my $tx = test_xpath_html($mech->content);

    $tx->is('count(//div[@id="page"]//table)',
            5, 'four collection lists are present');

    $tx->is('count(//div[@id="page"]//table[1]//th)',
            7, 'artist collection list has 7 cols');

    $tx->is('count(//div[@id="page"]//table[2]//th)',
            7, 'event collection list has 7 cols');

    $tx->is('count(//div[@id="page"]//table[3]//th)',
            7, 'release collection list has 7 cols');

    $tx->is('count(//div[@id="page"]//table[4]//th)',
            7, 'work collection list has 7 cols');

    $tx->is('//div[@id="page"]//table[1]/tbody/tr[1]/td[3]',
            1, 'number of artists is correct');

    $tx->is('//div[@id="page"]//table[2]/tbody/tr[1]/td[3]',
            2, 'number of events is correct');

    $tx->is('//div[@id="page"]//table[3]/tbody/tr[1]/td[3]',
            2, 'number of releases is correct');

    $tx->is('//div[@id="page"]//table[4]/tbody/tr[1]/td[3]',
            2, 'number of works is correct');

    $tx->is('count(//div[@id="page"]//table[5]//th)',
            6, 'collaborative release collection list has 6 cols');

    $tx->is('count(//div[@id="page"]//table[5]//tbody/tr)',
            2, 'collaborative release collection list has 2 collections');
};

test 'No collections' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/user/editor5/collections');
    my $tx = test_xpath_html($mech->content);

    $tx->is('//div[@id="page"]/p',
            'editor5 has no public collections.editor5 isn’t collaborating in any public collections.',
            'editor has no collections');
};

test 'Viewing someone elses collections' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/user/editor2/collections');
    my $tx = test_xpath_html($mech->content);

    $tx->is('count(//div[@id="page"]//table[1]//th)',
            5, q(other editor's collection list has 5 cols));

    $tx->is('count(//div[@id="page"]//table[2]//th)',
            6, q(other editor's collaborative collection list has 6 cols));
};

test 'Invalid user' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/user/notauser/collections');
    is($mech->status, HTTP_NOT_FOUND);
};

1;
