package t::MusicBrainz::Server::Controller::ArtistCredit::Show;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic artist credit data is correctly listed in an
artist credit page, and whether trying to load a nonexistent artist credit
fails gracefully.

=cut

test 'Basic artist credit data appears on main page' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+artistcredit');

    $mech->get_ok('/artist-credit/945c079d-374e-4436-9448-da92dedef3cf', 'Fetched artist credit page');
    html_ok($mech->content);

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//ul[@id="artist-credit-artists"]/li)',
        '2',
        'There are two artists listed for the artist credit',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//ul[@id="artist-credit-recordings"]/li)',
        '1',
        'There is one recording listed for the artist credit',
    );
    $tx->is(
        '//ul[@id="artist-credit-recordings"]/li[1]',
        'Under Pressure',
        'The recording is named "Under Pressure"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//ul[@id="artist-credit-release-groups"]/li)',
        '1',
        'There is one release group listed for the artist credit',
    );
    $tx->is(
        '//ul[@id="artist-credit-release-groups"]/li[1]',
        'Under Pressure',
        'The release group is named "Under Pressure"',
    );
};

test 'Page redirects to the current MBID when needed' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/artist-credit/1', 'Fetched artist credit page using row ID');
    ok(
        $mech->uri =~ qr{/artist-credit/945c079d-374e-4436-9448-da92dedef3cf$},
        'Artist credit row ID redirects to artist credit MBID',
    );

    $mech->get_ok('/artist-credit/261f02c2-75a6-313f-9dd8-1716f73f3ce8', 'Fetched artist credit page using an old MBID');
    ok(
        $mech->uri =~ qr{/artist-credit/945c079d-374e-4436-9448-da92dedef3cf$},
        'Artist credit old MBID redirects to artist credit new MBID',
    );
};

test 'Page fails gracefully when sent an invalid ID' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/artist-credit/2775611341');
    is(
        $mech->status(),
        404,
        'Trying to fetch an AC by DB ID with a non-existent integer 404s',
    );

    $mech->get('/artist-credit/undefined');
    is(
        $mech->status(),
        400,
        'Trying to fetch an AC by an incorrectly formatted ID 400s',
    );

    $mech->text_contains(
        '\'undefined\' is not a valid MusicBrainz ID',
        'The message about the text being an invalid ID is shown',
    );
};

1;
