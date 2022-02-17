package t::MusicBrainz::Server::Controller::Instrument::Artists;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );
use utf8;

with 't::Mechanize', 't::Context';

=head2 Test description

  This test checks whether the instrument artists page correctly lists artists
  connected to the instrument.

=cut

test 'Test instrument artists page' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_instrument',
    );

    $mech->get_ok(
        '/instrument/089f123c-0f7d-4105-a64e-49de81ca8fa4/artists',
        'Fetched the instrument artists page',
    );
    html_ok($mech->content);
    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the artists table',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[1]',
        'Salvatore Accardo',
        'The entry is for Salvatore Accardo',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[6]',
        'teacher, instrument (as “violino”), instrument',
        'The entry lists both relevant roles, "instrument" and "teacher", with one credit too',
    );
};

1;
