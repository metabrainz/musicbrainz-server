package t::MusicBrainz::Server::Controller::Instrument::Show;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

  This test checks whether basic instrument data is correctly listed on an
  instrument's index (main) page.

=cut

test 'Basic instrument data appears on the index page' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_instrument',
    );

    $mech->get_ok(
        '/instrument/089f123c-0f7d-4105-a64e-49de81ca8fa4',
        'Fetched the instrument index page',
    );
    html_ok($mech->content);
    my $tx = test_xpath_html($mech->content);
    $mech->title_like(
        qr/violin/,
        'The page title contains the instrument name',
    );
    $mech->title_like(
        qr/String instrument/,
        'The page title contains the instrument type',
    );
    $tx->is(
        '//div[@id="content"]/div/h1/a',
        'violin',
        'The page header lists the instrument name',
    );
    $mech->content_contains(
        'Soprano of modern violin family',
        'The disambiguation is listed',
    );
    $mech->content_contains(
        'The most famous member of the violin family',
        'The instrument description is shown',
    );

    $mech->content_contains(
        'String instrument',
        'The instrument type is listed',
    );

    $mech->content_contains('Test annotation 1', 'The annotation is shown');

    $mech->content_contains(
        'Last updated on 2021-11-04',
        'The last updated date is listed',
    );

    # Tab links
    $mech->content_contains(
        '/instrument/089f123c-0f7d-4105-a64e-49de81ca8fa4/artists',
        'A link to the artists page is present',
    );
    $mech->content_contains(
        '/instrument/089f123c-0f7d-4105-a64e-49de81ca8fa4/releases',
        'A link to the releases page is present',
    );
};

1;
