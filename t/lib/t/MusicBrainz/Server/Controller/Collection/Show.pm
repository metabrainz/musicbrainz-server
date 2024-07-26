package t::MusicBrainz::Server::Controller::Collection::Show;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Constants qw( :edit_status );
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

=head2 Test description

This test checks whether collection index pages display the expected data.

=cut

test 'Collection view has link back to all collections' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok(
        '/collection/f34c079d-374e-4436-9448-da92dedef3cd',
        'Fetched a collection by the logged in user',
    );
    my $tx = test_xpath_html($mech->content);

    $tx->ok(
        '//div[@id="content"]/div/p/span[@class="small"]/a[contains(@href,"/editor1/collections")]',
        q(There is a link to the owner's collections page),
    );
    $tx->is(
        '//div[@id="content"]/div/p/span[@class="small"]/a',
        'See all of your collections',
        'The link has the expected text',
    );

    $mech->get_ok(
        '/collection/f34c079d-374e-4436-9448-da92dedef3cb',
        'Fetched a collection by a different user',
    );

    $tx = test_xpath_html($mech->content);
    $tx->ok(
        '//div[@id="content"]/div/p/span[@class="small"]/a[contains(@href,"/editor2/collections")]',
        q(There is a link to the owner's collections page),
    );
    $tx->is(
        '//div[@id="content"]/div/p/span[@class="small"]/a',
        q(See all of editor2's public collections),
        'The link has the expected text',
    );
};

test 'Collection descriptions are shown, but avoid spam risk' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok(
        '/collection/f34c079d-374e-4436-9448-da92dedef3cb',
        'Fetched collection page while logged in',
    );
    $mech->content_like(
        qr/Testy!/,
        'Collection description of beginner/limited user shows for logged in user',
    );

    $mech->get('/logout');

    $mech->get_ok(
        '/collection/f34c079d-374e-4436-9448-da92dedef3cb',
        'Fetched collection page while logged out',
    );

    my $tx = test_xpath_html($mech->content);
    $mech->content_unlike(
        qr/Testy!/,
        'Collection description of beginner/limited user hidden for logged out user',
    );
    $mech->content_contains(
        'This content is hidden to prevent spam',
        'An informative message is shown instead',
    );
    $tx->ok(
        '//div[@class="description"]/p[@class="deleted"]',
        'The description section is marked to be displayed as deleted',
    );

    note('We remove the beginner flag from the editor');
    $test->c->sql->do('UPDATE editor SET privs = 0 WHERE id = 2');

    $mech->get_ok(
        '/collection/f34c079d-374e-4436-9448-da92dedef3cb',
        'Fetched collection page while logged out, after making user non-limited',
    );
    $mech->content_like(
        qr/Testy!/,
        'Collection description of non-limited user also shows when logged out',
    );

    $mech->get_ok(
        '/collection/f34c079d-374e-4436-9448-da92dedef3c9',
        'Fetched collection page with no description',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        '//div[@class="description"]',
        '',
        'The description section has no content (is not visible)',
    );

};

test 'Private collection pages are private' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/collection/a34c079d-374e-4436-9448-da92dedef3cb');
    is($mech->status, HTTP_FORBIDDEN, 'Main collection page is private');
    $mech->get('/collection/a34c079d-374e-4436-9448-da92dedef3cb/subscribers');
    is($mech->status, HTTP_FORBIDDEN, 'Subscribers page is private');

    $mech->get('/collection/f34c079d-374e-4436-9448-da92dedef3cd');
    is($mech->status, HTTP_OK, 'Main collection page is visible to owner');
    $mech->get('/collection/f34c079d-374e-4436-9448-da92dedef3cd/subscribers');
    is($mech->status, HTTP_OK, 'Subscribers page is visible to owner');

    $mech->get('/collection/a34c079d-374e-4436-9448-da92dedef3ce');
    is($mech->status, HTTP_OK, 'Main collection page is visible to collaborator');
    $mech->get('/collection/a34c079d-374e-4436-9448-da92dedef3ce/subscribers');
    is($mech->status, HTTP_OK, 'Subscribers page is visible to collaborator');
};

test 'Unknown collection fails gracefully' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/collection/f34c079d-374e-1337-1337-aaaaaaaaaaaa');
    is($mech->status, HTTP_NOT_FOUND, 'Non-existing collection 404s');
};

test 'MBS-13570: Can show an artist collection' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/4ef57e84-4d9c-4da3-9621-6a71de8f227d');
    $mech->content_like(
        qr/Led Zeppelin/,
        'Artist is visible on the collection page',
    );
};

1;
