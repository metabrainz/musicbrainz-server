package t::MusicBrainz::Server::Controller::ArtistCredit::Show;
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

    $mech->get_ok('/artist-credit/1', 'Fetched artist credit page');
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

test 'Page fails gracefully when sent an invalid ID' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/artist-credit/2775611341');
    is(
        $mech->status(),
        404,
        'Trying to fetch an AC by DB ID with a too-large integer 404s',
    );

    $mech->get('/artist-credit/undefined');
    is(
        $mech->status(),
        404,
        'Trying to fetch an AC by an invalid ID 404s',
    );

    $mech->text_contains(
        'Sorry, we could not find an artist credit with that ID.',
        'The message about the AC not being found is shown',
    );
};

1;
