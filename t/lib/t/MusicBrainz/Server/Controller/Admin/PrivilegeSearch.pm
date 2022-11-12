package t::MusicBrainz::Server::Controller::Admin::PrivilegeSearch;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( test_xpath_html );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the privilege search works as expected, and whether
it's blocked for non-admins.

=cut

test 'Privilege search is blocked for non-admins' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+privileges');

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'normal_editor', password => 'password' } );

    $mech->get('/admin/privilege-search');
    is(
        $mech->status,
        403,
        'Normal user cannot access the privilege search page',
    );
};

test 'Privilege search results are correct' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+privileges');

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'admin', password => 'password' } );

    $mech->get_ok(
        '/admin/privilege-search',
        'Admin can access the privilege search page',
    );

    $mech->get_ok(
        '/admin/privilege-search?privilege-search.auto_editor=1',
        'Fetch results for autoeditor search (not exact)',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '4',
        'There are four entries in the user list',
    );
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '4',
        'There are four entries in the user list',
    );
    $tx->ok(
        '//table[@class="tbl"]/tbody/tr/td[contains(.,"relationship_editor")]',
        'An editor with more flags than just autoeditor is still shown',
    );

    $mech->get_ok(
        '/admin/privilege-search?privilege-search.show_exact=1&privilege-search.auto_editor=1',
        'Fetch results for autoeditor search (exact)',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the user list',
    );
    $tx->not_ok(
        '//table[@class="tbl"]/tbody/tr/td[contains(.,"relationship_editor")]',
        'An editor with more flags than just autoeditor is not shown',
    );

    $mech->get_ok(
        '/admin/privilege-search?privilege-search.auto_editor=1&privilege-search.link_editor=1',
        'Fetch results for autoeditor + relationship editor search (not exact)',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the user list',
    );
    $tx->ok(
        '//table[@class="tbl"]/tbody/tr/td[contains(.,"admin")]',
        'An editor with more flags than just autoeditor and relationship editor is still shown',
    );

    $mech->get_ok(
      '/admin/privilege-search?privilege-search.show_exact=1&privilege-search.auto_editor=1&privilege-search.link_editor=1',
      'Fetch results for autoeditor + relationship editor search (exact)',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the user list',
    );
    $tx->not_ok(
        '//table[@class="tbl"]/tbody/tr/td[contains(.,"admin")]',
        'An editor with more flags than just autoeditor and relationship editor is not shown',
    );
};

1;
